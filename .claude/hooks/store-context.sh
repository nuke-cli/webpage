#!/usr/bin/env bash
# PostToolUse(ExitPlanMode): push the approved plan and this session's context on the current
# branch to nuke-cli/claude, as webpage/context/<branch>/plan_<ticket>.md and context.txt
# (issue #18). context.txt keeps one block per session ID, so other sessions' blocks survive. The
# files are written through the GitHub contents API, not git push, so they cannot retrigger a push
# hook.

repo=${STORE_CONTEXT_REPO:-nuke-cli/claude}
base=${STORE_CONTEXT_DIR:-webpage/context}
dir=${CLAUDE_PROJECT_DIR:-$PWD}

input=$(cat)

tool=$(jq -r '.tool_name // ""' <<<"$input")
session=$(jq -r '.session_id // ""' <<<"$input")
transcript=$(jq -r '.transcript_path // ""' <<<"$input")

[ "$tool" = ExitPlanMode ] || exit 0
[ -n "$session" ] || exit 0

# The branch being rebased counts as the current branch. A detached HEAD has no folder.
branch=$(cd "$dir" && .claude/skills/commit/branch.sh)
branch=${branch#rebasing in }
[ -n "$branch" ] && [ "$branch" != DETACHED ] || exit 0

ticket=$(grep -Eo '^[0-9]+' <<<"$branch")
plan_path="$base/$branch/plan${ticket:+_$ticket}.md"
context_path="$base/$branch/context.txt"

tmp=$(mktemp -d) || exit 0
trap 'rm -rf "$tmp"' EXIT

jq -r '.tool_input.plan // .tool_response.plan // ""' <<<"$input" >"$tmp/plan.md"
[ -s "$tmp/plan.md" ] && [ "$(tr -d '[:space:]' <"$tmp/plan.md")" ] || exit 0

# Only this branch's prompts and Claude's text replies. fromjson? skips a line that is still being
# written.
block=""
if [ -f "$transcript" ]; then
	block=$(jq -rR --arg branch "$branch" '
		fromjson?
		| select(.type == "user" or .type == "assistant")
		| select(.gitBranch == $branch)
		| select((.isMeta // false) or (.isSidechain // false) | not)
		| (if .type == "user" then "[user]" else "[claude]" end) as $who
		| (.message.content // "")
		| if type == "string" then . else (map(select(.type == "text") | .text) | join("\n")) end
		| select(length > 0)
		| "\($who) \(.)"
	' "$transcript")
fi
start="==== START OF SESSION_ID $session ===="
end="==== END OF SESSION_ID $session ===="

# Prints the blob sha of $1 on main, or nothing when the file doesn't exist yet. Fails on any other
# API error.
remote_sha() {
	local meta
	if meta=$(gh api "repos/$repo/contents/$1?ref=main" 2>&1); then
		jq -r '.sha // ""' <<<"$meta"
	else
		grep -q 'HTTP 404' <<<"$meta"
	fi
}

# Uploads local file $2 to $1 on main, replacing blob $3 (empty for a new file). Content equal to
# the remote is not uploaded. A PUT with a stale sha (the file changed since remote_sha) fails, and
# the caller retries.
put_file() {
	[ "$3" = "$(git hash-object "$2")" ] && return 0
	jq -n --rawfile c "$2" --arg sha "$3" --arg msg "docs(claude): update $branch ${1##*/}" \
		--arg session "$session" '{
		message: "\($msg)\n\nsession_id: \($session)",
		content: ($c | @base64),
		branch: "main"
	} + (if $sha == "" then {} else { sha: $sha } end)' |
		gh api -X PUT "repos/$repo/contents/$1" --input - >/dev/null 2>&1
}

upload_plan() {
	local sha
	sha=$(remote_sha "$plan_path") && put_file "$plan_path" "$tmp/plan.md" "$sha"
}

# Merges the remote context.txt with this session's block, replacing the session's previous block,
# and uploads it. The remote content is read by blob sha, so it is the version the PUT replaces.
upload_context() {
	local sha
	sha=$(remote_sha "$context_path") || return 1
	: >"$tmp/remote.txt"
	if [ -n "$sha" ]; then
		gh api -H 'Accept: application/vnd.github.raw' "repos/$repo/git/blobs/$sha" \
			>"$tmp/remote.txt" 2>/dev/null || return 1
	fi
	{
		awk -v s="$start" -v e="$end" '$0 == s { skip = 1; next } $0 == e { skip = 0; next } !skip' \
			"$tmp/remote.txt"
		printf '%s\n%s\n%s\n' "$start" "$block" "$end"
	} >"$tmp/context.txt" || return 1
	put_file "$context_path" "$tmp/context.txt" "$sha"
}

pushed=() failed=()
if upload_plan || upload_plan; then pushed+=("${plan_path##*/}"); else failed+=("${plan_path##*/}"); fi
if [ -n "$block" ]; then
	if upload_context || upload_context; then pushed+=(context.txt); else failed+=(context.txt); fi
fi

msg="Session context:"
[ ${#pushed[@]} -gt 0 ] && msg+=" pushed ${pushed[*]} to $repo/$base/$branch/."
[ ${#failed[@]} -gt 0 ] && msg+=" push of ${failed[*]} to $repo failed."

jq -n --arg m "$msg" '{ systemMessage: $m }'

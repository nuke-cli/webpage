#!/usr/bin/env bash
# PostToolUse(ExitPlanMode): push the approved plan to nuke-cli/claude as
# webpage/context/<branch>/plan_<ticket>.md (issue #18). The file is written through the GitHub
# contents API, not git push, so it cannot retrigger a push hook.

repo=${STORE_CONTEXT_REPO:-nuke-cli/claude}
base=${STORE_CONTEXT_DIR:-webpage/context}
dir=${CLAUDE_PROJECT_DIR:-$PWD}

input=$(cat)

tool=$(jq -r '.tool_name // ""' <<<"$input")
session=$(jq -r '.session_id // ""' <<<"$input")

[ "$tool" = ExitPlanMode ] || exit 0
[ -n "$session" ] || exit 0

# The branch being rebased counts as the current branch. A detached HEAD has no folder.
branch=$(cd "$dir" && .claude/skills/commit/branch.sh)
branch=${branch#rebasing in }
[ -n "$branch" ] && [ "$branch" != DETACHED ] || exit 0

ticket=$(grep -Eo '^[0-9]+' <<<"$branch")
plan_path="$base/$branch/plan${ticket:+_$ticket}.md"

tmp=$(mktemp -d) || exit 0
trap 'rm -rf "$tmp"' EXIT

jq -r '.tool_input.plan // .tool_response.plan // ""' <<<"$input" >"$tmp/plan.md"
[ -s "$tmp/plan.md" ] && [ "$(tr -d '[:space:]' <"$tmp/plan.md")" ] || exit 0

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

if upload_plan || upload_plan; then
	msg="Plan pushed to $repo/$plan_path."
else
	msg="Plan push to $repo/$plan_path failed."
fi

jq -n --arg m "$msg" '{ systemMessage: $m }'

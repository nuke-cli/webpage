---
name: commit
description: Commit the staged changes using the project's commit message standard.
disable-model-invocation: true
argument-hint: '[optional hint for the commit message]'
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git commit -F -:*)
---

## Context

- Branch: !`b=$(git branch --show-current); if [ -z "$b" ]; then for d in rebase-merge rebase-apply; do f=$(git rev-parse --git-path "$d/head-name"); [ -z "$b" ] && [ -f "$f" ] && b="rebasing in $(sed "s#^refs/heads/##" "$f")"; done; fi; echo "${b:-DETACHED}"`
- Datetime: !`date '+%Y-%m-%dT%H:%M:%S%z'`
- Session ID: ${CLAUDE_SESSION_ID}
- Status: !`git status --short`
- Staged diff: !`git diff --cached`
- Recent commits: !`git log -5 --format=%s`

User hint: $ARGUMENTS

## Task

Create a single commit from the **staged** changes only. Do not stage, unstage, or modify files.
Unstaged and untracked changes must stay out of the commit, even if they look related.
Run exactly `git commit -F -` with no other flags or paths: never `-a`/`--all`, `-i`/`--include`,
`-o`/`--only`, `--amend`, or file paths, since each of these commits more than the index.
Describe only what appears in the staged diff.
If nothing is staged, stop and tell the user.
If the branch is `DETACHED`, stop and tell the user that HEAD is detached outside of a rebase.

The message must follow this format exactly:

```
<type>: <message>

<body>

branch: <branch>
session_id: <session id>
datetime: <datetime>
```

- `type`: a Conventional Commits type (`feat`, `fix`, `chore`, `docs`, `refactor`, `style`, `test`, `perf`, `build`, `ci`, `revert`).
- `message`: short, lowercase, imperative summary, no trailing period (e.g. `feat: implement wireframe`).
- `body`: optional. A `- ` bulleted list of the changes. Omit it for trivial commits, together with one of its surrounding blank lines, so a
  single blank line separates the summary from `branch:`.
- `branch`, `session_id`, `datetime`: copy the values from the Context section verbatim.
- Add nothing else to the message: no blank lines other than the ones shown, no extra trailers.

Pass the message through a heredoc so newlines are preserved:

```sh
git commit -F - <<'EOF'
<message>
EOF
```

Do not use `--no-verify`. If the Husky `pre-commit` hook fails, report the error instead of retrying around it.
Finish by showing the output of `git log -1`.

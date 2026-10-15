#!/bin/sh
# Prints the branch for the commit message: the current branch, "rebasing in <branch>"
# during a rebase, or DETACHED when HEAD is detached outside of a rebase.
b=$(git branch --show-current)
if [ -z "$b" ]; then
	for d in rebase-merge rebase-apply; do
		f=$(git rev-parse --git-path "$d/head-name")
		if [ -z "$b" ] && [ -f "$f" ]; then
			# A rebase started from a detached HEAD (e.g. `git checkout <sha>; git rebase main`)
			# has no branch, so git writes the literal text "detached HEAD" to head-name.
			# Without this check the output would be "rebasing in detached HEAD" and the
			# skill would commit with it instead of stopping. Treat it as DETACHED for now.
			h=$(sed 's#^refs/heads/##' "$f")
			[ "$h" != "detached HEAD" ] && b="rebasing in $h"
		fi
	done
fi
echo "${b:-DETACHED}"

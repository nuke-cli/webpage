#!/bin/sh
# Prints the branch for the commit message: the current branch, "rebasing in <branch>"
# during a rebase of a branch, or DETACHED when HEAD is not on a branch.
b=$(git branch --show-current)
if [ -z "$b" ]; then
	for d in rebase-merge rebase-apply; do
		f=$(git rev-parse --git-path "$d/head-name")
		if [ -z "$b" ] && [ -f "$f" ]; then
			# Only accept a real branch ref. A rebase started from a detached HEAD
			# (e.g. `git checkout <sha>; git rebase main`) has no branch, so git writes the
			# literal text "detached HEAD" to head-name. Without this check the output would
			# be "rebasing in detached HEAD" and the skill would commit with it instead of
			# stopping. Anything that isn't refs/heads/<branch> is treated as DETACHED for now.
			h=$(head -n 1 "$f" | tr -d '\r')
			case "$h" in
			refs/heads/?*) b="rebasing in ${h#refs/heads/}" ;;
			esac
		fi
	done
fi
echo "${b:-DETACHED}"

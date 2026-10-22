# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Marketing/landing webpage for nuke-cli. Svelte 3 + TypeScript + SCSS, bundled with Rollup 2 into a single IIFE (`public/build/bundle.js` + `bundle.css`) and served statically with `sirv-cli`. Node >= 24 (`engines` in `package.json`; Docker image `node:24-alpine`).

Design and product context lives outside this repo, in https://github.com/nuke-cli/claude/tree/main/webpage. Check it before UI work. It currently holds `nuke-cli_home.jpg`, the home page mockup, which is a greyscale wireframe. Its grey circles are placeholders for logos that don't exist yet. Fetch files with `gh api repos/nuke-cli/claude/contents/webpage/<file> -H 'Accept: application/vnd.github.raw'`.

## Commands

Scripts run via `npm run <script>` or `yarn <script>`.

- `app:dev` — Rollup watch mode; also spawns `start -- --dev` and livereloads on changes to `public/`. Serves on port 4000.
- `build` — production build (minified with terser). Production mode is inferred from the absence of `ROLLUP_WATCH`, not from `NODE_ENV`.
- `start` — serve `public/` with sirv on `0.0.0.0:4000`. Requires a prior `build`.
- `lint` — Prettier `--write` over `.svelte` and `.ts` files. Wired to the Husky `pre-commit` hook (`yarn lint`), but the hook is not active in this checkout: `core.hooksPath` is unset and `.husky/_/husky.sh` is missing, so nothing is linted on commit.
- `app:up` / `app:down` — `docker-compose up -d` / `down`. Container `svelte-application`; host/container ports come from `LOCAL_PORT` / `DOCKER_PORT` in `.env` (both 4000).

There is no test runner or type-check script configured.

## Architecture notes

- Entry: `src/main.ts` mounts `src/App.svelte` onto `document.body`. `public/index.html` loads the built bundle; `public/build/` is gitignored.
- Components live in `src/components/<Name>/component.svelte` and are re-exported from `src/components/index.ts`. Utilities are re-exported from `src/utils/index.ts`.
- `@utils` and `@components` path aliases are defined twice and must stay in sync: `tsconfig.json` `paths` (type-checking) and `@rollup/plugin-alias` in `rollup.config.js` (bundling).
- Component styling uses BEM-like class names (`Text`, `Text--bold`) built with the local `classnames(main, [{ class, condition }])` helper, and scoped `<style lang="scss">` blocks.
- Docker: the image builds the bundle at image build time (`RUN npm run build`) and serves it with `yarn start`. Only `./src` is volume-mounted and nothing watches it, so source changes need `docker compose up -d --build` to show up.
- Node is not installed on the host machine; run npm commands in a container, e.g. `docker run --rm -v "$PWD":/app -v nuke_nm:/app/node_modules -w /app node:24-alpine npm run build`.

## Commits

Commit messages follow this format (issue #17):

```
<type>: <message>

<body>

branch: <branch>
session_id: <session id>
datetime: <datetime>
```

- `type` is a Conventional Commits type; `message` is a short, lowercase, imperative summary.
- `body` is an optional `- ` bulleted list. Without it, one blank line separates the summary from `branch:`.
- `branch` is the current branch, `rebasing in <branch>` during a rebase. Don't commit when HEAD is not on a branch.
- `datetime` uses `date '+%Y-%m-%dT%H:%M:%S%z'` (e.g. `2026-10-16T00:25:32+0100`).
- No other lines or trailers.

The `/commit` skill (`.claude/skills/commit/`) writes these messages. It only runs when the user types `/commit` (`disable-model-invocation: true`); when asked to commit without it, follow the same format by hand. It commits staged changes only, via `git commit -F -`, and never stages files. `branch.sh` computes the `branch` value; the skill calls it by a path relative to the repo root.

## Session context

The `.claude/hooks/store-context.sh` hook (wired in `.claude/settings.json`, issue #18) shares Claude's plan and session context with the `nuke-cli/claude` repo, under `webpage/context/<branch>/`:

- `plan_<ticket>.md`: the approved plan. The ticket is the branch's leading number (`plan.md` when there is none).
- `context.txt`: the session's prompts and Claude's text replies on that branch, one `==== START/END OF SESSION_ID <id> ====` block per session. Each run replaces only its own session's block, so other sessions and machines are kept.

It runs when a plan is approved (`ExitPlanMode`) and after a successful `git push` run by Claude (not on `--dry-run`). On a push it uploads the context and the last plan approved on the branch in that session; without one, the remote plan is left alone. Git commands run outside Claude Code don't trigger it. Files are committed straight to `main` through the GitHub contents API, which needs `gh auth login` with push access; unchanged files aren't re-committed. `STORE_CONTEXT_REPO` and `STORE_CONTEXT_DIR` override the target repo and folder.

`nuke-cli/claude` is public, so a session's prompts and replies are published on every plan approval and push.

## Gotchas

`gotchas/<branch>.txt` records code-review findings for a branch, grouped as fixed (with commit refs), open, and by design. Read the file for the code you're changing before working on it, and update it when a finding is fixed.

## Style

Prettier config (`.prettierrc`): tabs, single quotes, semicolons, print width 100, `prettier-plugin-svelte`.

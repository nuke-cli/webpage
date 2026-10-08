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
- `lint` — Prettier `--write` over `.svelte` and `.ts` files. Runs automatically on commit through the Husky `pre-commit` hook (`yarn lint`).
- `app:up` / `app:down` — `docker-compose up -d` / `down`. Container `svelte-application`; host/container ports come from `LOCAL_PORT` / `DOCKER_PORT` in `.env` (both 4000).

There is no test runner or type-check script configured.

## Architecture notes

- Entry: `src/main.ts` mounts `src/App.svelte` onto `document.body`. `public/index.html` loads the built bundle; `public/build/` is gitignored.
- Components live in `src/components/<Name>/component.svelte` and are re-exported from `src/components/index.ts`. Utilities are re-exported from `src/utils/index.ts`.
- `@utils` and `@components` path aliases are defined twice and must stay in sync: `tsconfig.json` `paths` (type-checking) and `@rollup/plugin-alias` in `rollup.config.js` (bundling).
- Component styling uses BEM-like class names (`Text`, `Text--bold`) built with the local `classnames(main, [{ class, condition }])` helper, and scoped `<style lang="scss">` blocks.
- Docker: the image builds the bundle at image build time (`RUN npm run build`) and serves it with `yarn start`. Only `./src` is volume-mounted and nothing watches it, so source changes need `docker compose up -d --build` to show up.
- Node is not installed on the host machine; run npm commands in a container, e.g. `docker run --rm -v "$PWD":/app -v nuke_nm:/app/node_modules -w /app node:24-alpine npm run build`.

## Style

Prettier config (`.prettierrc`): tabs, single quotes, semicolons, print width 100, `prettier-plugin-svelte`.

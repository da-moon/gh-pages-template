# gh-pages template (Deno + Vite + TS)

A minimal static site starter for GitHub Pages. Uses Vite + TypeScript, run
entirely through Deno's Node compatibility. Works out of the box inside the
provided nix flake dev shell.

## Stack

- Deno 2.x (Node compat for npm specifiers)
- Vite 7 + TypeScript 5.9
- Nix flake dev shell for repeatable tooling

## Getting started

```bash
# enter dev shell (recommended)
nix develop

# start dev server (http://localhost:5173)
deno task dev
```

## Tasks (deno.json)

- `deno task dev` - Vite dev server
- `deno task build` - Production build to `dist/`
- `deno task preview` - Preview the built site
- `deno task typecheck` - TypeScript `--noEmit`
- `deno task fmt` - Format
- `deno task lint` - Lint
- `deno task test` - Deno tests

## Validation flow

Run before pushing:

```bash
deno task fmt --check
deno task lint
deno task typecheck
deno task test   # optional until tests exist
deno task build
```

## Deploy to GitHub Pages

1. `deno task build` (outputs to `dist/`).
2. Publish `dist/` to a `gh-pages` branch (example):

```bash
git worktree add -B gh-pages dist
cd dist && git add . && git commit -m "Publish" && git push origin gh-pages
cd .. && git worktree remove dist
```

3. In repository settings, configure Pages to serve from the `gh-pages` branch
   root.

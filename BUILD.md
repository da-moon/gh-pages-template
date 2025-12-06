# Build & Development (Deno First)

This project is a minimal Vite + TypeScript site run through Deno's Node
compatibility layer. All commands are available inside the nix flake dev shell.

## Prerequisites
- Use the dev shell: `nix develop` (provides `deno`).
- Outside nix, install Deno 2.x and ensure `npm:` specifiers are enabled by
  default (they are in Deno 2).

## Core Tasks (deno.json)
```bash
deno task dev        # Start Vite dev server
deno task build      # Production build -> dist/
deno task preview    # Preview the built site
deno task typecheck  # TypeScript (npm:tsc --noEmit)
deno task fmt        # Format with deno fmt
deno task lint       # Lint with deno lint
deno task test       # Deno tests (std/assert, no setup required)
```

## Typical Workflows
- Day-to-day: `nix develop` -> `deno task dev`.
- Quick validation before pushing: `deno task fmt && deno task lint && deno task typecheck && deno task build`.
- Preview the production build locally: `deno task preview` (after `deno task build`).

## Project Notes
- Source lives in `src/` (`main.ts`, `style.css`).
- TypeScript is configured via `tsconfig.json`; bundler mode is enabled.
- No extra scaffolding or domain rules-keep changes small and explicit.

## GitHub Pages Deploy
1) Build: `deno task build` (outputs to `dist/`).
2) Publish `dist/` to `gh-pages` branch (one option):
   ```bash
   git worktree add -B gh-pages dist
   cd dist && git add . && git commit -m "Publish" && git push origin gh-pages
   cd .. && git worktree remove dist
   ```
   Or use a CI step that runs `deno task build` and pushes `dist/` to
   `gh-pages`.
3) In GitHub Pages settings, serve from the `gh-pages` branch root.

## Troubleshooting
- Missing deps: run inside `nix develop` or ensure Deno 2.x is installed.
- Type errors: `deno task typecheck` for full output; dev server also reports.
- Port conflicts: Vite defaults to 5173-set `PORT` or use `--host --port` via
  `deno run -A npm:vite -- --host --port 4173` if needed.

## CI Suggestion
Minimal CI sequence:
```bash
deno task fmt --check
deno task lint
deno task typecheck
deno task build
```

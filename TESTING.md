# Testing (Deno)

This project is tiny, so we keep testing simple and Deno-first.

## Commands
- Unit/integration: `deno task test`
- Lint: `deno task lint`
- Format check: `deno fmt --check`

## Where tests live
- Collocate small tests near code (e.g., `src/main.test.ts`).
- Use Deno std asserts; no extra setup required.

## Sample test
```ts
// src/main.test.ts
import { assertStringIncludes } from "jsr:@std/assert";

Deno.test("renders greeting", () => {
  const html = `<h1>Hello, World!</h1>`;
  assertStringIncludes(html, "Hello, World!");
});
```

## Manual checks (current site)
- Start dev server: `deno task dev` then open http://localhost:5173.
- Verify the hero text renders: "Hello, World!" and supporting paragraph.
- Build check: `deno task build` and optionally `deno task preview` to smoke test the production bundle.

## CI suggestion
Run, in order:
```bash
deno task fmt --check
deno task lint
deno task typecheck
deno task test
deno task build
```

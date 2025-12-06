/// <reference lib="deno.ns" />
import { assertStringIncludes } from "jsr:@std/assert";

Deno.test("renders hello world copy", () => {
  const html = `<div><h1>Hello, World!</h1><p>Your GitHub Pages site is live.</p></div>`;
  assertStringIncludes(html, "Hello, World!");
  assertStringIncludes(html, "GitHub Pages site is live");
});

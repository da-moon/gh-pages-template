import { defineConfig } from 'vite'

// Use an env-provided base (set in CI) to ensure assets work on GitHub Pages.
// Fallback to '/' for local dev or user/username.github.io sites.
const base = process.env.VITE_BASE || '/'

export default defineConfig({
  base,
})

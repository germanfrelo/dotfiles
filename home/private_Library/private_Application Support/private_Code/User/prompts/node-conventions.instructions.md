---
name: Node.js conventions
description: "Node.js scripting conventions and module architecture: ESM, native APIs, no unnecessary dependencies, shared config, code organisation. Applies to JavaScript files and package.json; TypeScript excluded."
applyTo: "**/*.{js,mjs,cjs},**/package.json"
---

- Use ESM (`import`/`export`, `"type": "module"` in `package.json`). Never use CommonJS (`require`, `module.exports`) in new files. Do not migrate existing CommonJS files unless explicitly asked; when importing a CommonJS module from ESM, use default import syntax.
- Use native `fetch` (Node 18+). Do not add `node-fetch`, `axios`, or similar HTTP libraries unless native fetch lacks a required feature (e.g., HTTP/2, streaming uploads, automatic retries); document the missing capability in a code comment. Always check `response.ok` and throw on non-2xx responses. Use `AbortSignal.timeout(ms)` to enforce request timeouts.
- Use Node built-ins (`fs/promises`, `path`, `crypto`, `os`) whenever they provide the required functionality. Only add an npm package if the built-in lacks a specific needed feature; document that feature in a comment.
- Extract shared constants (API base URLs, filesystem paths, auth key names, timeouts, retry counts) into `config.js` and import from it. Script-local constants used in only one file may remain inline. Never hardcode shared values in individual scripts.
- Extract shared utility functions used by two or more scripts into `utils.js` — typical candidates: reading and JSON-parsing a file, git operations, string normalisation, filesystem helpers. Prefer a named utility (e.g. `loadJson(filePath)`) over repeating `readFile` + `JSON.parse` inline.
- Extract HTTP fetch helpers, auth header builders, rate-limit sleeps, and per-resource fetch functions into a dedicated `<service>-api.js` (e.g. `github-api.js`). The main script should contain only control flow, not raw `fetch` calls.
- When extracting a function to a shared module, convert any outer-scope variables it closes over into explicit parameters (e.g. `githubHeaders(token)` not `githubHeaders()` closing over `token`).
- Split code into separate modules from the start — do not wait for scripts to grow large before extracting shared code.
- Set `"private": true` in `package.json` unless it explicitly sets `publishConfig` or the README documents the package as a published library.
- After changing any field in `package.json`, run `npm install` to update `package-lock.json`.

---
trigger: model_decision
description: "JavaScript and Node.js module architecture conventions. Applies to JavaScript files."
---

# JavaScript Conventions

- Use ESM (`import`/`export`) in all new files. Do not migrate existing CommonJS files unless asked; import CommonJS modules into ESM via default imports.
- Prefer Node built-ins (`fs/promises`, `path`, `crypto`, `os`) and native `fetch` (Node 18+) over third-party packages (`axios`, `node-fetch`, etc.); only add a package when a built-in lacks a required feature (e.g., HTTP/2, streaming uploads, retries) and document why in a comment.
- With `fetch`, always check `response.ok` (throwing on non-2xx responses) and enforce timeouts via `AbortSignal.timeout(ms)`.
- Modularize from the start rather than waiting for scripts to grow:
  - **`config.js`**: Shared constants (API base URLs, paths, auth key names, timeouts, retry counts); keep single-script constants inline.
  - **`utils.js`**: Helpers shared by two or more scripts (e.g., `loadJson(filePath)` instead of repeating `readFile` + `JSON.parse`, Git wrappers, string/path helpers).
  - **`<service>-api.js`** (e.g., `github-api.js`): HTTP helpers, auth headers, rate-limit sleeps, and resource fetchers so entry scripts contain only control flow.
- Pass dependencies as explicit parameters in shared modules rather than closing over outer-scope variables (e.g., `githubHeaders(token)`, not `githubHeaders()`).

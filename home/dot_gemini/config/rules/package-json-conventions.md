---
trigger: model_decision
description: "package.json configuration and maintenance conventions. Applies when creating or modifying package.json files."
---

# package.json Conventions

- Use `"type": "module"` in `package.json` for new projects; do not switch existing CommonJS packages to ESM unless requested.
- Set `"private": true` in `package.json` unless it explicitly sets `publishConfig` or the README documents the package as a published library.
- After modifying dependencies or package metadata in `package.json`, run `npm install` to update `package-lock.json`.

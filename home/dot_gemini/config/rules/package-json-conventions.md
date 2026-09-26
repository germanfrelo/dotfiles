---
trigger: model_decision
description: "Conventions for any project containing a package.json file."
---

# Package JSON Conventions

- Use `"type": "module"` in `package.json`.
- Set `"private": true` in `package.json` unless it explicitly sets `publishConfig` or the README documents the package as a published library.
- After changing any field in `package.json`, run `npm install` to update `package-lock.json`.

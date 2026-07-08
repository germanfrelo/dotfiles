---
status: accepted
date: 2026-06-22
---

# Remove ~/.editorconfig — prevent Prettier configuration hijacking

## Context and Problem Statement

When saving VS Code internal configuration files (such as `~/Library/Application Support/Code/User/settings.json`), the Prettier extension (`esbenp.prettier-vscode`) incorrectly appends trailing commas to `[jsonc]` blocks. This causes the native "JSON: Sort Document" command to crash with an `addChildProperty` error.

Despite explicit rules defined within `settings.json`:

```json
"[jsonc]": {
   "prettier.trailingComma": "none"
}
```

Prettier completely bypasses these workspace settings. The root cause is the existence of an `.editorconfig` file located in the user's home directory (`~/.editorconfig`).

When Prettier resolves its configuration hierarchy, the discovery of an `.editorconfig` file triggers its "local configuration mode." This strictly enforces the `.editorconfig` parameters while silently falling back to Prettier's factory defaults (which force trailing commas in v3+) for all other settings, fundamentally locking out any overrides defined in VS Code's `settings.json`.

## Considered Options

- Retain `~/.editorconfig` and disable EditorConfig in Prettier via `"prettier.useEditorConfig": false`
- Retain `~/.editorconfig` and bypass Prettier for JSON via `"editor.defaultFormatter": "vscode.json-language-features"`
- Remove the global `~/.editorconfig` entirely

## Decision Outcome

Chosen option: **Remove `~/.editorconfig` entirely**, because eliminating the file prevents Prettier from silently entering local configuration mode, ensuring it respects `settings.json` overrides. This solves the root cause at the file-system level, preventing global dotfiles from polluting local project or editor formatting environments.

## Consequences

- `~/.editorconfig` is entirely absent from the home directory.
- chezmoi [`remove_` source files](https://www.chezmoi.io/reference/source-state-attributes/) are used to enforce this: `home/remove_dot_editorconfig` (guards `~/.editorconfig`). chezmoi deletes the target files on every `chezmoi apply`, preventing accidental re-creation by any tool or agent.
- If global fallback formatting rules (e.g., standardizing line endings or tab widths across untracked directories) are ever needed again, they must be configured directly within VS Code's `settings.json`, or project-specific `.editorconfig` files must be strictly maintained in individual repositories.

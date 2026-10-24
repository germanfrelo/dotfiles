# dotfiles — Agent Instructions

User's dotfiles across multiple macOS machines, managed with chezmoi. See [README.md](/README.md) for repository overview and bootstrapping guides.

## Source structure

The **source state root** is `$(chezmoi source-path)`, which resolves to the `home/` subdirectory of this repository (not `~/.local/share/chezmoi`).

## Pre-operation workflow

- **Invariant:** `chezmoi unmanaged` must return empty stdout; if unmanaged files are listed, stop and surface them to the user.
- **Required checks:** Always run `chezmoi status`, `chezmoi unmanaged`, and `chezmoi ignored` before/after operations and before committing.

## chezmoi commands and applying changes

- **Read-only commands (allowed):** `diff`, `status`, `cat`, `managed`, `unmanaged`, `ignored`, `data`, `doctor`, `execute-template`. Use `chezmoi diff --use-builtin-diff` in the terminal because default `chezmoi diff` opens VS Code without stdout.
- **State-modifying commands (never execute):** `add`, `apply`, `forget`, `merge`, `merge-all`, `re-add`, `update`. When suggesting any state-modifying command, provide the preview (`--dry-run --verbose` or `-nv`) first, followed by the execution command (`--verbose` or `-v`).
- **Existing managed files:** Edit only source files under `home/`, then verify with `chezmoi diff --use-builtin-diff`. Never edit destination files directly.
- **New dotfiles:** Never scaffold new configurations from scratch in source or destination directories; instruct the user to create the destination file and run `chezmoi add <target-path>`.
- **Secrets exception:** Author new `private_` files directly in the source tree as templates using `onepasswordRead` (never paste raw secrets). If an existing destination file was edited directly, verify the source template does not use `onepassword*` before suggesting `chezmoi re-add`; if it does use `onepassword*`, abort and ask the user to re-template manually.
- **Enforced absent files:** Follow the [Enforcing Absent Files Runbook](/docs/runbooks/enforcing-absent-files.md) to declare, verify, or revert absent dotfiles.

## Commit conventions

### Type (required)

Categorize commits by functional intent and delivered impact rather than file location:

- **Deliverables (`feat`, `fix`):** Any change that adds, updates, or fixes configuration settings, CLI tools, aliases, packages, or machine runtime behavior delivered to `$HOME` via chezmoi, or executable AI rules/skills under `home/dot_gemini/`. Never use `chore`, `style`, or `docs` for behavioral changes.
- **Non-behavioral edits:**
  - **`refactor`:** Restructures source templates, conditionals, attributes, or syntax without altering functional runtime behavior or introducing new capabilities.
  - **`docs`:** Repository documentation (`README.md`, root `AGENTS.md`, `docs/`) and strictly comment-only edits within managed configs under `home/`.
  - **`style`:** Code formatting, Prettier/linter reformatting, whitespace, or indentation with no logic change.
  - **`chore`:** Repository maintenance, root devDependencies (`package.json`, root `Brewfile`), Git hooks (`.husky/`), linter configurations, Git blame ignore lists, and non-behavioral suppression comment updates across managed configs.

### Scope (required)

- **Single tool or domain:** Use the managed target tool's name (e.g., `git`, `zsh`, `vscode`, `gh`, etc.).
- **Cross-cutting changes:** When a commit spans multiple tools cohesively, use a thematic scope (e.g., `terminal` in 80ebc92, `shell` in 7dad770).
- **Non-obvious path mappings:**
  - AI rules and skills (`home/dot_gemini/config/rules/`, `home/dot_gemini/config/skills/`, or root `AGENTS.md`) → `ai`.
  - `home/dot_gemini/` app settings and CLI config (excluding rules and skills) → `antigravity`.
  - `home/.chezmoiscripts/**/*install-packages*` or `home/.chezmoiscripts/**/*brewfile*` → `homebrew` (all package installation changes, including template directives and renames).
  - `home/.chezmoi*` config files and templates (e.g., `.chezmoi.toml.tmpl`, `.chezmoiignore`) and other `.chezmoiscripts/` → `chezmoi`.
  - Root `README.md` → `readme`.
  - `docs/decisions/` → `decisions`.
  - `docs/runbooks/` → `runbooks`.
  - `scripts/` → `scripts`.

## Repository path resolution

Never hardcode absolute or home-relative paths (`~/...`, `$HOME/...`, `os.homedir()`) when referencing the local repositories directory in scripts ([ADR 0005](/docs/decisions/0005-repos-directory-path-architecture.md)):

1. **Relative paths (preferred):** Resolve sibling repositories relative to the script's location (e.g., `path.resolve(__dirname, '../../')` in Node.js, or `$(cd "$(dirname "$0")/../.." && pwd)` in Bash).
2. **Environment variable fallback:** When relative resolution is impossible, read `$REPOS_DIR` with a relative fallback (e.g., `process.env.REPOS_DIR || path.resolve(__dirname, '../../')`) because GUI apps, Cron, and CI may lack shell environment variables.

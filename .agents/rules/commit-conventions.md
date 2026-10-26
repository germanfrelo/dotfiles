---
trigger: model_decision
description: "Commit conventions, conventional commit types, required scopes, and path mappings for the dotfiles repository. Applies when drafting, reviewing, staging, or committing Git changes."
---

# Commit Conventions

## Type

Required.

Categorize commits by functional intent and delivered impact rather than file location:

- **Deliverables (`feat`, `fix`):** Any change that adds, updates, or fixes configuration settings, CLI tools, aliases, packages, or machine runtime behavior delivered to `$HOME` via chezmoi, or executable AI rules/skills under `home/dot_gemini/`. Never use `chore`, `style`, or `docs` for behavioral changes.
- **Non-behavioral edits:**
  - **`refactor`:** Restructures source templates, conditionals, attributes, or syntax without altering functional runtime behavior or introducing new capabilities.
  - **`docs`:** Repository documentation (`README.md`, `docs/`, and root `AGENTS.md` and `.agents/`) and strictly comment-only edits within managed configs under `home/`.
  - **`style`:** Code formatting, Prettier/linter reformatting, whitespace, or indentation with no logic change.
  - **`chore`:** Repository maintenance, root devDependencies (`package.json`, root `Brewfile`), Git hooks (`.husky/`), linter configurations, Git blame ignore lists, and non-behavioral suppression comment updates across managed configs.

## Scope

Required.

- **Single tool or domain:** Use the managed target tool's name (e.g., `git`, `zsh`, `vscode`, `gh`, etc.).
- **Cross-cutting changes:** When a commit spans multiple tools cohesively, use a thematic scope (e.g., `terminal` in 80ebc92, `shell` in 7dad770).
- **Non-obvious path mappings:**
  - AI rules and skills (root `AGENTS.md` and `.agents/`, `home/dot_gemini/config/rules/`, `home/dot_gemini/config/skills/`) → `ai`.
  - `home/dot_gemini/` app settings and CLI config (excluding rules and skills) → `antigravity`.
  - `home/.chezmoiscripts/**/*install-packages*` or `home/.chezmoiscripts/**/*brewfile*` → `homebrew` (all package installation changes, including template directives and renames).
  - `home/.chezmoi*` config files and templates (e.g., `.chezmoi.toml.tmpl`, `.chezmoiignore`) and other `.chezmoiscripts/` → `chezmoi`.
  - Root `README.md` → `readme`.
  - `docs/decisions/` → `decisions`.
  - `docs/runbooks/` → `runbooks`.
  - `scripts/` → `scripts`.

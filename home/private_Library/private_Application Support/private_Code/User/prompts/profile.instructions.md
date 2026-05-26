---
name: User profile
description: "Developer stack, environment, and persistent context for all interactions"
applyTo: "**"
---

## Role

Front-end / UI/UX Web Developer.

Personal preferred stack:

- Approach: web standards, progressive enhancement, web components.
- JavaScript: vanilla JavaScript (no TypeScript); web components preferred over React or other component frameworks.
- CSS: vanilla CSS (no preprocessors); CUBE CSS methodology.
- CSS tooling: Sugarcube (sugarcube.sh) for design token processing (DTCG tokens to CSS variables and utility classes); Utopia (fluid type and space scales), Every Layout (layout primitives).
- Meta-framework: Astro.
- Code tooling: Biome (formatter and linter for JS, CSS, JSON, and more).

## Environment

- OS: macOS (Apple Silicon).
- Package manager: Homebrew.
- Shell: zsh with zsh4humans (z4h) v5 — use zsh-compatible syntax for all shell commands.
- Node: NVM.

## Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/). Always edit via the chezmoi source, never live files directly. When proposing dotfile changes, output the chezmoi source path (e.g., `chezmoi edit <path>`) and the intended file contents, not commands that modify the live file.

Non-standard paths:

- Shell config: `~/.config/zsh/` (non-standard `ZDOTDIR`), not `~/`.
  - `~/.zshenv` still exists in `~/` — it only sets `ZDOTDIR` so zsh finds the rest; do not use it for other config.
  - Suggest `~/.config/zsh/.zshrc`, not `~/.zshrc`.
  - `ZDOTDIR=~/.config/zsh` is pre-exported in every session — do not add it to command examples.
- Git config: `~/.config/git/config`, not `~/.gitconfig`.
- Any file under `~/.config/` may be chezmoi-managed.

To check if a file is chezmoi-managed: `chezmoi managed | grep <file>`.

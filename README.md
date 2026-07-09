# dotfiles

My dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## Managed files

See [MANAGED.txt](/MANAGED.txt) for the full file list.

## Repository layout

| Path                              | Purpose                                                    |
| --------------------------------- | ---------------------------------------------------------- |
| `home/`                           | Chezmoi source root (`.chezmoiroot = home`)                |
| `docs/chezmoi.md`                 | Personal chezmoi reference and cheat sheet                 |
| `scripts/`                        | Automation scripts                                         |
| `.husky/`                         | Git hook scripts                                           |
| `.github/copilot-instructions.md` | AI agent instructions with machine-readable chezmoi config |

## Features

- **Always-current managed file list** — the pre-commit hook regenerates and auto-stages `MANAGED.txt` whenever files in the chezmoi source root (`home/`) or the generator script (`scripts/managed.js`) are staged, with no manual step required.
- **Auto-generated documentation** — `npm run chezmoi:sync` reads `home/.chezmoi.toml.tmpl` and injects a "My configuration" table into `docs/chezmoi.md` and a machine-readable TOML block into `.github/copilot-instructions.md`, so both always reflect the actual chezmoi setup without manual editing.
- **Continuous documentation sync** — a GitHub Action opens a pull request whenever chezmoi config source files change, keeping generated documentation in sync with configuration at all times.
- **Unified chezmoi reference** — [`docs/chezmoi.md`](/docs/chezmoi.md) documents every command, workflow, and template pattern with examples tailored to this setup (`$ZDOTDIR`, `$XDG_CONFIG_HOME`, `$(chezmoi source-path)`).
- **AI-ready agent instructions** — `.github/copilot-instructions.md` gives Copilot and other AI agents full context on repo conventions, chezmoi source structure, and configuration deviations from chezmoi defaults.
- **Guardrails on every commit** — Prettier formatting is enforced on staged files via Husky + lint-staged; post-checkout and post-merge hooks warn when `package-lock.json` changes and prompt to run `npm ci`.
- **Automated dependency review** — a GitHub Action scans every pull request for dependency vulnerabilities and licence issues before merge.

## npm scripts

| Script         | Description                                                                                         |
| -------------- | --------------------------------------------------------------------------------------------------- |
| `managed`      | Regenerates `MANAGED.txt` from the current chezmoi source state                                     |
| `chezmoi:sync` | Injects auto-generated config sections into `docs/chezmoi.md` and `.github/copilot-instructions.md` |
| `format`       | Formats all files with Prettier                                                                     |
| `format:check` | Checks formatting without writing                                                                   |

## Tooling

- [Prettier](https://prettier.io/) — formats JS, JSON, Markdown, and YAML.
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) — lints all Markdown files.
- [Husky](https://typicode.github.io/husky/) + [lint-staged](https://github.com/lint-staged/lint-staged) — enforces formatting on every commit.

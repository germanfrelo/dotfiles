# dotfiles

My dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## Managed files

See [MANAGED.txt](/MANAGED.txt) for the full file list.

## Repository layout

| Path              | Purpose                                                    |
| ----------------- | ---------------------------------------------------------- |
| `home/`           | Chezmoi source root (`.chezmoiroot = home`)                |
| `docs/chezmoi.md` | Personal chezmoi reference and cheat sheet                 |
| `scripts/`        | Automation scripts                                         |
| `.husky/`         | Git hook scripts                                           |
| `AGENTS.md`       | AI agent instructions with machine-readable chezmoi config |

## Features

- **Always-current managed file list** — the pre-commit hook regenerates and auto-stages `MANAGED.txt` whenever files in the chezmoi source root (`home/`) or the generator script (`scripts/managed.js`) are staged, with no manual step required.
- **Unified chezmoi reference** — [`docs/chezmoi.md`](/docs/chezmoi.md) documents every command, workflow, and template pattern with examples.
- **AI-ready agent instructions** — `AGENTS.md` gives Copilot and other AI agents full context on repo conventions, chezmoi source structure, and configuration deviations from chezmoi defaults.
- **Guardrails on every commit** — Prettier formatting is enforced on staged files via Husky + lint-staged; post-checkout and post-merge hooks warn when `package-lock.json` changes and prompt to run `npm ci`.
- **Automated dependency review** — a GitHub Action scans every pull request for dependency vulnerabilities and licence issues before merge.

## npm scripts

| Script         | Description                                                     |
| -------------- | --------------------------------------------------------------- |
| `managed`      | Regenerates `MANAGED.txt` from the current chezmoi source state |
| `format`       | Formats all files with Prettier                                 |
| `format:check` | Checks formatting without writing                               |

## Tooling

- [Prettier](https://prettier.io/) — formats JS, JSON, Markdown, and YAML.
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) — lints all Markdown files.
- [Husky](https://typicode.github.io/husky/) + [lint-staged](https://github.com/lint-staged/lint-staged) — enforces formatting on every commit.

## Bootstrapping a new machine

After `chezmoi` completes its initial run on a fresh machine, execute the following manual bootstrap actions in order.

### 1. Reload your shell session

```sh
exec zsh
```

### 2. SSH (`personal` only)

Right after all packages are installed via chezmoi and before proceeding with any Git operations:

#### 2.1. Enable managing SSH with 1Password

1. Open the 1Password desktop app and log in.
2. Navigate to `Settings` → `Developer` and verify that `Use the SSH Agent` is enabled.

This activates the 1Password agent socket referenced in `~/.ssh/config`, allowing Git to authenticate network operations via your SSH key.

#### 2.2. Switch this 'dotfiles' repository's remote from HTTPS to SSH

Since `chezmoi init` cloned this repository over HTTPS during the initial bootstrapping, switch its remote to SSH:

```sh
cd "$(chezmoi source-path)/.." && git remote set-url origin git@github.com:germanfrelo/dotfiles.git
```

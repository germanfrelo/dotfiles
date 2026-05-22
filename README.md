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

## Post-Installation / Bootstrapping

After `chezmoi` completes its initial run on a fresh machine, remember to execute the following manual actions.

### Clone your personal GitHub repos

1. Reload your shell to load the newly-deployed `.zshrc` (which sets `$REPOS_DIR` and `$FORKS_DIR`):
   ```sh
   exec zsh
   ```
2. Authenticate with the GitHub CLI:
   ```sh
   gh auth login
   ```
3. Run the clone script:
   ```sh
   $(chezmoi source-path)/scripts/clone-github-repos.sh
   ```

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

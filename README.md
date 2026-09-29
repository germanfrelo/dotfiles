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

### 3. Local repositories (`personal` only)

Select and **batch** clone _your_ GitHub repositories locally. Authenticate and choose one of the batch cloning methods.

Reference: [GitHub CLI manual](https://cli.github.com/manual/).

#### 3.1. Authenticate via GitHub CLI

Run:

```sh
gh auth login
```

During the interactive prompts, select:

- **What account do you want to log into?** `GitHub.com`.
- **What is your preferred protocol for Git operations?** `SSH`.
- **Upload your SSH public key to your GitHub account?** `Skip` (your SSH key is already registered on your GitHub account).
- **How would you like to authenticate GitHub CLI?** `Login with a web browser`.

#### 3.2A. Interactive method (recommended)

> [!NOTE]
> This method requires [`fzf`](https://github.com/junegunn/fzf). If it's not installed, either [install it using Homebrew](https://github.com/junegunn/fzf#installation) (recommended) or use the alternative [manual method](#32b-manual-method-fallback) below.

Review and select the repos you want to clone interactively (`Ctrl+A` to select all, `Tab` on `dotfiles` or unwanted entries to deselect, `Enter` to clone):

**Source repos:**

```sh
# Clone owned source repos into $REPOS_DIR
cd "${REPOS_DIR}"
if command -v fzf >/dev/null 2>&1; then
  gh repo list --source --no-archived --limit 1000 --json name --jq '.[].name' \
    | fzf -m --bind 'ctrl-a:select-all,ctrl-d:deselect-all' --header 'Tab: toggle | Ctrl+A: select all | Enter: clone' \
    | xargs -n 1 sh -c 'echo "----------" && gh repo clone "$1"' _
else
  echo "fzf not found. Either install it ('brew install fzf') or use the fallback method below." >&2
fi
```

**Forks:**

```sh
# Clone personal account forks into $FORKS_DIR
cd "${FORKS_DIR}"
if command -v fzf >/dev/null 2>&1; then
  gh repo list --fork --no-archived --limit 1000 --json name --jq '.[].name' \
    | fzf -m --bind 'ctrl-a:select-all,ctrl-d:deselect-all' --header 'Tab: toggle | Ctrl+A: select all | Enter: clone' \
    | xargs -n 1 sh -c 'echo "----------" && gh repo clone --no-upstream "$1"' _
else
  echo "fzf not found. Either install it ('brew install fzf') or use the fallback method below." >&2
fi
```

#### 3.2B. Manual method (fallback)

**Source repos:**

```sh
# 1. Export the repository names to a temporary file and open it in your editor:
cd "${REPOS_DIR}"
gh repo list --source --no-archived --limit 1000 --json name --jq '.[].name' > /tmp/repos.txt
code /tmp/repos.txt

# 2. Remove any unwanted repositories, save and run:
xargs -n 1 sh -c 'echo "----------" && gh repo clone "$1"' _ < /tmp/repos.txt
```

**Forks:**

```sh
# 1. Export the repository names to a temporary file and open it in your editor:
cd "${FORKS_DIR}"
gh repo list --fork --no-archived --limit 1000 --json name --jq '.[].name' > /tmp/forks.txt
code /tmp/forks.txt

# 2. Remove any unwanted repositories, save and run:
xargs -n 1 sh -c 'echo "----------" && gh repo clone --no-upstream "$1"' _ < /tmp/forks.txt
```

## Homebrew packages

### Overview

Homebrew packages are managed by this repository, even across multiple machines. Supported Homebrew package types: `brew`, `mas` and `npm`.

The list of installed packages is saved in `Brewfile` files. You do not need to edit these files manually. When you run standard commands (e.g., `brew install <pkg>`), a background script automatically appends the package to the `Brewfile` on your machine. You can then use chezmoi to commit the updated file to the repository. The next time you run `chezmoi apply` on your other machines, they will automatically read the updated file and install the missing packages.

### Prerequisites

- Homebrew must be installed (see [brew.sh](https://brew.sh/)).
- A `machine_type` custom data variable defined in the chezmoi configuration file at `~/.config/chezmoi/chezmoi.toml` (see [.chezmoi.toml.tmpl](/home/.chezmoi.toml.tmpl)).

### Involved files

Source files in this repository:

- `home/.chezmoiscripts/darwin/run_onchange_after_install-packages.sh.tmpl`
- `home/private_dot_config/homebrew/personal/Brewfile`
- `home/private_dot_config/homebrew/work/Brewfile`
- `home/private_dot_config/zsh/dot_zshrc.tmpl`

Target files on the local machine:

- `~/.config/homebrew/{{ .machine_type }}/Brewfile` (resolved via the `{{ .machine_type }}` variable in `~/.config/chezmoi/chezmoi.toml`)

### Workflow

#### 1. Day-to-day usage

The usual workflow is:

1. Install/uninstall a package via `brew/mas/npm install/uninstall`.
2. Decide if the package belongs only on this machine or should be deployed to all machines.
3. Update the chosen target `Brewfile` via `brew bundle add/remove --file=PATH`.

What this repository does:

Steps 2 and 3 are automated (kind of). Whenever you run `brew/mas/npm install/uninstall` commands, a custom Zsh function in [`home/private_dot_config/zsh/dot_zshrc.tmpl`](/home/private_dot_config/zsh/dot_zshrc.tmpl) intercepts them in the background, executes the native command immediately, and automatically updates the `Brewfile`. It updates your machine-specific `Brewfile` by default (e.g., `~/.config/homebrew/personal/Brewfile`), so you can continue your workflow without interruptions.

#### 2. Backing up changes to the repository

When ready to back up the changes to the dotfiles repository:

1. Run `chezmoi status` and `chezmoi diff` to review the modified files.
2. Open `~/.config/homebrew/{{ .machine_type }}/Brewfile` in an editor.
3. Run `chezmoi re-add ~/.config/homebrew/{{ .machine_type }}/Brewfile` to sync the modified target files back to the repository source files.
4. Verify and then commit the changes.

#### 3. Pulling and applying changes

1. Pull the latest changes from the repository via `chezmoi update`.
2. Run `chezmoi apply`. Chezmoi copies the updated source `Brewfile`s to `~/.config/homebrew/` (replacing the existing ones if they exist).
3. The [`run_onchange_after_install-packages.sh.tmpl`](/home/.chezmoiscripts/darwin/run_onchange_after_install-packages.sh.tmpl) script automatically detects that the source files have changed and executes `brew bundle check` and `brew bundle install` on the target file. All missing packages are installed natively, so the local machine exactly matches the repository.

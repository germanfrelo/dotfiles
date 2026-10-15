---
status: accepted
date: 2026-10-12
---

# Personal GitHub Repositories Storage and Cloning

## Context and Problem Statement

When setting up a new personal machine, I need to clone my personal GitHub repositories while keeping active local workspaces organized and protected from data loss.
This process requires determining three key architectural factors: directory storage taxonomy, execution mechanism, and repository filtering strategy.

How should personal repositories and forks be stored locally, authenticated, and cloned during machine bootstrapping?

## Decision Drivers

- Must separate owned source repositories, personal account forks, and disposable third-party scratch clones into clear workspaces.
- Must protect active development and unpushed branches on forks from accidental deletion during system cleanups.
- Must adhere to ADR 0005 for single source of truth environment variable path resolution.
- Must avoid maintenance overhead of bespoke scripts for infrequent operations.
- Must integrate transparently with 1Password SSH Agent on personal machines.
- Must maintain full user visibility and control over which repositories are cloned.

## Considered Options

- Option 1A: 3-tier directory storage taxonomy (`~/Developer/repos` for owned source repos, `~/Developer/forks` for account forks, `~/Downloads/repos` for disposable scratch clones).
- Option 1B: Monolithic directory (`~/Developer/repos` for all repositories and forks).
- Option 1C: Placing forks in `~/Downloads/repos` alongside disposable scratch clones.
- Option 2A: Native GitHub CLI review workflow (`fzf` multi-select + text file fallback).
- Option 2B: Standalone bespoke script (`scripts/clone-github-repos.sh`).
- Option 2C: Chezmoi automated lifecycle script (`run_once_after_` script).
- Option 3A: Interactive user review (fuzzy picker or editable manifest file before cloning).
- Option 3B: Automated blocklist filtering (regex skip list in script).
- Option 3C: Automated allowlist filtering (hardcoded list in script/dotfiles).

## Decision Outcome

Chosen options:

- Option 1A (3-tier directory storage taxonomy), because it provides permanent, safe storage under `~/Developer/` for all code tied to my GitHub account (`repos/` for owned source code and `forks/` for external contributions), while leaving `~/Downloads/repos` strictly for throwaway, unmanaged third-party test clones that can be purged at any time.
- Option 2A (Native GitHub CLI review workflow), because it eliminates maintenance overhead of an 80+ line bespoke Bash script for an operation executed only once per fresh machine setup. It leverages native `gh repo clone` safety against overwriting existing directories, standard UNIX piping, and requires zero repo-level script maintenance.
- Option 3A (Interactive user review), because piping `gh repo list` to an interactive fuzzy picker (`fzf -m`) or a temporary editable text file (`/tmp/repos.txt`) provides 100% visibility into which repositories will be cloned. It avoids hardcoding brittle skip regexes or maintenance-heavy allowlists.

### Consequences

- Good, because active development and unpushed branches on account forks (such as porting branches) are safely stored in `~/Developer/forks` rather than exposed to automated `Downloads` folder cleanup utilities.
- Good, because the directory architecture strictly adheres to ADR 0005, with paths defined once as environment variables in `.zshrc`.
- Good, because zero custom scripts are maintained in the repository (`scripts/clone-github-repos.sh` is eliminated).
- Good, because the developer retains full visual control over cloned repositories at bootstrap time without managing static lists.
- Good, because 1Password SSH Agent handles authentication biometrically via Touch ID without storing private keys on disk.
- Bad, because it requires a manual post-installation command execution rather than achieving fully unattended zero-touch dotfile application.

### Confirmation

The architecture is confirmed by executing the bootstrap commands documented in [`README.md`](/README.md) in a shell session where `$REPOS_DIR` and `$FORKS_DIR` are exported:

1. 1Password desktop app is unlocked and configured with "Use the SSH Agent" enabled (`personal` machine only).
2. `gh auth login` configures the GitHub CLI for SSH operations without uploading new keys.
3. Native `gh repo list` queries available repositories.
4. Repositories are reviewed interactively via `fzf -m` (or edited in `/tmp/repos.txt`).
5. The `xargs` pipeline clones selected repositories into `$REPOS_DIR` (`~/Developer/repos`) and `$FORKS_DIR` (`~/Developer/forks`), printing a clean divider between each repository.
6. Disposable scratch clones remain isolated in `~/Downloads/repos` and are untouched.

## Pros and Cons of the Options

### Option 1A: 3-tier directory storage taxonomy

Organizes local git workspaces into three distinct directories based on ownership and lifecycle: owned source projects in `~/Developer/repos`, personal account forks in `~/Developer/forks`, and temporary third-party clones in `~/Downloads/repos`.

- Good, because all code associated with the user's GitHub account is safely stored under `~/Developer/`.
- Good, because `~/Downloads/repos` is established as an ephemeral scratchpad that can be safely wiped without inspecting its contents.
- Good, because it prevents accidental clutter between first-party projects and external forks.
- Bad, because it introduces two separate paths (`$REPOS_DIR` and `$FORKS_DIR`) into shell configuration instead of one.

### Option 1B: Monolithic directory

Stores all repositories (both owned source projects and forks) in a single directory (`~/Developer/repos`).

- Good, because it simplifies environment variables to a single `$REPOS_DIR`.
- Bad, because it blends third-party codebases and personal creations into a single directory, making file-system browsing cluttered.

### Option 1C: Placing forks in `~/Downloads/repos` alongside disposable scratch clones

Directs `FORKS_DIR` to `~/Downloads/repos` under the assumption that all forks are temporary.

- Good, because it minimizes the number of directories under `~/Developer/`.
- Bad, because forks containing active PRs or unpushed work (e.g., porting an upstream tool before author deletion) risk accidental deletion during OS or browser cleanup routines.
- Bad, because it conflates permanent personal GitHub account forks with throwaway third-party clones.

### Option 2A: Native GitHub CLI review workflow

Executes repository cloning using standard CLI pipelines (interactive `gh repo list | fzf -m | xargs ...`) documented in [`README.md`](/README.md).

- Good, because it eliminates bespoke script maintenance and fragile regex parsing.
- Good, because `gh repo clone` natively detects and skips existing directories safely.
- Good, because it natively inherits `$REPOS_DIR` and `$FORKS_DIR` from the active shell environment as mandated by ADR 0005.
- Bad, because it requires manual command execution in the terminal after dotfiles deployment.

### Option 2B: Standalone bespoke script

Implements cloning via an executable Bash script (`scripts/clone-github-repos.sh`) maintained in the dotfiles repository.

- Good, because all clone steps and checks are bundled into a single executable command.
- Bad, because maintaining 80+ lines of custom Bash error handling, subshell environment checks, and argument parsing creates unnecessary debt for an operation executed once every few years.

### Option 2C: Chezmoi automated lifecycle script

Executes repository cloning during `chezmoi apply` via a `run_once_after_` script.

- Good, because it automates cloning during dotfiles application without manual intervention.
- Bad, because it suffers from the First-Run Paradox: newly deployed environment variables from `.zshrc` are not yet active in the current shell session.
- Bad, because it halts unattended `chezmoi apply` if GitHub CLI authentication has not been established.

### Option 3A: Interactive user review

Allows the user to interactively select repositories via `fzf -m` or edit a generated plain text list before cloning.

- Good, because it provides complete visibility into which repositories will be downloaded.
- Good, because it avoids hardcoded skip lists or allowlists that go stale over time.
- Bad, because it requires a few seconds of interactive user engagement during setup.

### Option 3B: Automated blocklist filtering

Fetches all non-archived repositories using `gh repo list` and excludes specific repositories using a skip regular expression.

- Good, because newly created repositories are automatically synchronized without modifying dotfiles configuration.
- Bad, because it requires maintaining a skip regex for repositories that should not be cloned.

### Option 3C: Automated allowlist filtering

Maintains an explicit array of repository names in the script or configuration.

- Good, because it guarantees deterministic downloads and prevents downloading unwanted forks.
- Bad, because every new repository created requires manually updating dotfiles configuration.

## More Information

- [ADR 0005: Repos directory path architecture](/docs/decisions/0005-repos-directory-path-architecture.md).

# Documentation architecture diagnosis

The diagnosis of the documentation problem is exact:

1. **The 3-layer architecture**:
   This repository is not just a configuration folder; it is an integrated environment manager with three distinct layers:
   - **Layer 1: Software** (Homebrew packages, CLI tools, GUI apps, fonts).
   - **Layer 2: Configurations** (chezmoi dotfiles across Zsh, Git, VS Code, Loop, etc.).
   - **Layer 3: Workspaces** (Directory taxonomy and repository cloning across `$REPOS_DIR` and `$FORKS_DIR`).

2. **The 2 temporal lifecycles**:
   - **Day 0 (Initial Bootstrap / Provisioning)**: Executed once every few years on a fresh machine (`chezmoi init`, 1Password SSH, batch cloning, setting remote).
   - **Day 1+ (Daily Maintenance)**: Executed daily (`chezmoi apply`, package updates, dotfiles editing).

## Pattern A: Clean lifecycle separation (`docs/bootstrapping.md` or `BOOTSTRAP.md`) _(Recommended)_

Instead of fragmenting _parts_ of the bootstrap procedure into subfolders, separate the documentation cleanly along **lifecycle boundaries**:

- **[`README.md`](/README.md) (The Daily SSOT)**:
  Focuses 100% on what this repository is, how its 3 layers work (Software, Configs, Workspaces), and how to maintain it on a daily basis (`chezmoi apply`).
  For a fresh machine, it provides a single, prominent entry point:
  ```markdown
  ## Fresh machine setup

  Setting up a new machine from scratch? Follow the complete [Bootstrapping Guide](/docs/bootstrapping.md).
  ```
- **[`docs/bootstrapping.md`](/docs/bootstrapping.md) (The One-Time Provisioning SSOT)**:
  Contains the **entire, continuous, end-to-end checklist for setting up a new computer**:
  1. Prerequisites (macOS setup, Homebrew install).
  2. Chezmoi initialization (`chezmoi init`).
  3. Reload shell session.
  4. SSH and 1Password setup.
  5. Local repositories (GitHub CLI auth + batch clone pipelines + dotfiles remote switch).
  6. Any future post-install steps you plan to add.

### Why Pattern A works

- **Zero micro-fragmentation**: All fresh-machine steps live in **one single continuous document**. You never bounce back and forth between files while setting up a Mac.
- **Natural counterpart**: In commit `59005ce`, you already created [`docs/machine-wipe-checklist.md`](/docs/machine-wipe-checklist.md) for wiping a machine. [`docs/bootstrapping.md`](/docs/bootstrapping.md) is its natural, unified counterpart for bringing up a machine.
- **Scales cleanly**: As you add more setup steps (macOS defaults, app licenses, browser profiles), they all live in [`docs/bootstrapping.md`](/docs/bootstrapping.md) without adding a single line of bloat to [`README.md`](/README.md).

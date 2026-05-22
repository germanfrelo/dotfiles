---
status: accepted
date: 2026-10-08
---

# Cloning Personal GitHub Repositories

## Context and Problem Statement

When setting up a new personal machine, I need to automate the cloning of my personal GitHub repositories. This process requires determining several key architectural factors: location, timing, filtering mechanisms, and the execution script type.

This decision defines the workflow for synchronizing my development workspace on personal machines.

_(Note: This decision does not affect the location or bootstrapping of the `dotfiles` repository itself, which is handled independently)._

## Decision Drivers

- **XDG Compliance vs macOS Conventions:** Adhering to Linux/XDG standards versus native macOS developer expectations.
- **Security & Storage:** Preventing the accidental download of massive or sensitive repositories onto every machine.
- **The Bootstrap Dependency:** Cloning repositories requires Git credentials and potentially the GitHub CLI (`gh`), which must be installed and configured first.
- **Maintenance Burden:** The cognitive load of maintaining an explicit list of repositories.

## Considered Options

- **Option 1A:** Location - `~/Developer/repos` (macOS convention for active coding projects).
- **Option 1B:** Location - `~/.local/share/` (XDG standard, but meant for hidden application data, not user-editable source code).
- **Option 2A:** Mechanism - `run_once_after_` script (Executes at the end of `chezmoi apply`, guaranteeing tools are installed).
- **Option 2B:** Mechanism - Standalone manual script.
- **Option 3A:** Filtering - Allowlist (Explicit array of repos to clone).
- **Option 3B:** Filtering - Blocklist (Fetch everything from GitHub API except a denied list).

## Decision Outcome

Chosen options:

- **Option 1A** (`~/Developer/repos`) for location, because it natively aligns with macOS developer workflow expectations.
- **Option 2B** (Standalone manual script) for mechanism, because the goal is strict Single Source of Truth architecture. Automated scripts executed by `chezmoi` suffer from the "First-Run Paradox", where the active terminal session has not yet sourced the newly-deployed `.zshrc`. By executing the clone script manually in a fresh terminal session, the script can natively read `$REPOS_DIR` from the user's environment, eliminating the need to hardcode a fallback path.
- **Option 3B** (Blocklist) for filtering, because the cognitive burden of remembering to update an allowlist every time a new repository is created outweighs the minor risk of downloading an unwanted repository.

### Consequences

- Good, because the architecture strictly adheres to ADR 0005. The physical string is only written in `.zshrc`.
- Good, because new repositories are automatically considered for cloning without requiring changes to the dotfiles configuration.
- Good, because active development projects are highly visible in a standard user-space directory rather than hidden in XDG data directories.
- Bad, because it breaks the "zero-touch" automated setup philosophy of dotfiles by requiring a post-installation manual execution.
- Bad, because the blocklist approach risks blindly cloning massive repositories if the user forks a massive open-source monolith.

## Pros and Cons of the Options

### Option 1A: `~/Developer/repos`

- Good, because it provides a unified developer experience. All git repositories live in a single, predictable tree.
- Good, because it makes active projects highly visible and easy to open in IDEs.
- Bad, because it violates pure Linux XDG base directory specifications for configuration managers.

### Option 1B: `~/.local/share/`

- Good, because it strictly adheres to XDG base directory specifications.
- Bad, because it hides user-editable active development projects inside a hidden infrastructure directory.

### Option 2A: `run_once_after_` script

- Good, because it natively integrates with the `chezmoi` bootstrap lifecycle, delivering true automation.
- Bad, because it forces the massive cloning process to happen during dotfiles application, which can delay the setup process.

### Option 2B: Standalone manual script

- Good, because it provides the user with absolute control and allows for interactive prompts.
- Bad, because it requires a post-installation manual step, breaking the "zero-touch" philosophy.

### Option 3A: Allowlist

- Good, because it is highly deterministic and safe from massive accidental downloads.
- Bad, because it creates a permanent maintenance burden to manually update the list upon every new repository creation.

### Option 3B: Blocklist

- Good, because it creates a "set and forget" architecture where new projects are automatically included.
- Bad, because it risks downloading unwanted heavy or sensitive repositories if the blocklist is not aggressively maintained.

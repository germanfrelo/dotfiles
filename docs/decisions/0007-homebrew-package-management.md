---
status: accepted
date: 2026-10-10
---

# Homebrew Package Management

## Context and Problem Statement

chezmoi uses a declarative approach for dotfiles, but package installation requires imperative commands. When trying to sync Homebrew packages across multiple machines (e.g. personal vs work), developers typically either manually maintain a monolithic Brewfile with Go templates (which breaks local `brew install` commands) or embed packages directly inside chezmoi scripts (which interrupts terminal flow and ruins syntax highlighting). We need a package management architecture that handles "Common vs Specific" machine logic, automates local syncs to the repository, and safely reconciles both additions and subtractions without interrupting the developer's imperative daily workflow.

## Decision Drivers

- Must support machine-specific package isolation (e.g., `personal` vs `work`).
- Must preserve the standard, uninterrupted terminal workflow (`brew install <pkg>`).
- Must allow seamless cross-machine synchronization without destructive overwrites.
- Must keep the architecture simple and eliminate cognitive load during daily usage.

## Considered Options

- Option 1: Embed Brewfile inside a `run_onchange_` script via heredoc (Official approach)
- Option 2: Declarative package installation via `.chezmoidata.yaml` (Official approach)
- Option 3: Monolithic `Brewfile.tmpl` with Go conditionals
- Option 4: Interactive Zsh Wrapper
- Option 5: Template Orchestration (`common.Brewfile` + `personal.Brewfile` concatenated via `.chezmoitemplates`)
- Option 6: Dual Raw Target Files with Background Zsh Wrapper
- Option 7: Dual Raw Target Files with Startup Drift Alerts

## Decision Outcome

Chosen option: "Option 7: Dual Raw Target Files with Startup Drift Alerts", because it forces the user into the good habit of running `brew bundle add/remove` manually, treating Brewfile synchronization identically to standard dotfile synchronization. It elegantly solves the "Common vs Specific" machine problem while relying entirely on native tooling, removing complex wrapper logic while keeping the user completely safe from accidental drift.

### Consequences

- Good, because `chezmoi re-add` works flawlessly since the target Brewfiles contain zero Go templating logic to destroy.
- Good, because if the user forgets to update their Brewfile, standard terminal startups immediately warn them of the drift (using fast, synchronous checks) exactly like `chezmoi status` does.
- Good, because the complex and fragile background Zsh wrapper is completely eliminated.
- Bad, because the user must remember to manually type `brew bundle add <pkg>` after installing a new tool, adding a manual step to their workflow.
- Bad, because executing `brew bundle check` and `brew bundle cleanup` during terminal startup introduces a slight lag when opening new tabs.

### Confirmation

The workflow can be confirmed by pulling remote changes that affect an ignored Brewfile; running `chezmoi diff` will explicitly show the script's hash changing. Furthermore, installing a package via `brew install` without tracking it will immediately trigger a yellow terminal warning on the next tab open, demanding reconciliation.

## Pros and Cons of the Options

### Option 1: Embed Brewfile inside a `run_onchange_` script via heredoc

The official approach where a single `run_onchange_before_install-packages-darwin.sh.tmpl` script contains the Brewfile inside a `<<EOF` block. [Reference](https://www.chezmoi.io/user-guide/machines/macos/#use-brew-bundle-to-manage-your-brews-and-casks).

- Good, because it keeps all package logic strictly within the Chezmoi source directory.
- Bad, because it violates the "destination -> source" workflow. To install a package, the user must open the dotfiles repository, manually add the line, and run `chezmoi apply`. This interrupts standard terminal flow (`brew install <pkg>`).
- Bad, because syntax highlighting and Homebrew API descriptions are lost because the packages are embedded inside a `.sh.tmpl` script.

### Option 2: Declarative package installation via `.chezmoidata.yaml`

The official approach where packages are defined in `.chezmoidata.yaml` and a `run_onchange_` script loops through them to run imperative `brew install` commands. [Reference](https://www.chezmoi.io/user-guide/advanced/install-packages-declaratively/).

- Good, because it allows complex machine-specific grouping via YAML object nesting.
- Bad, because it entirely bypasses `brew bundle`, losing native support for `cleanup` and globally unified dependency resolution.
- Bad, because it requires manual editing of YAML files rather than utilizing native CLI tools.

### Option 3: Monolithic `Brewfile.tmpl` with Go conditionals

A single source file (`dot_Brewfile.tmpl`) that utilizes `{{ if eq .machine_type ... }}` logic to dynamically generate a specific target Brewfile.

- Good, because it provides a single, beautifully organized source file.
- Bad, because if the user runs `brew install` and updates the target Brewfile, running `chezmoi re-add` will completely overwrite the source file with the raw text, permanently deleting all Go templating logic.

### Option 4: Interactive Zsh Wrapper

We experimented with a Zsh wrapper that intercepted `brew install` and prompted the user via the terminal (`[c]ommon, [p]ersonal, [w]ork`) to categorize the package immediately.

- Good, because it maintained machine-specific separation while utilizing native `brew bundle add` to update target `.Brewfile`s directly on the machine.
- Bad, because the interactive prompt blocked the terminal, breaking automated scripts (e.g. `npm -g install` in CI) and adding cognitive load during standard development tasks.

### Option 5: Template Orchestration

We attempted to consolidate packages into a single `~/.config/homebrew/Brewfile` target by concatenating `.chezmoitemplates` components (`common.Brewfile` + `personal.Brewfile`). The Zsh wrapper would blindly append (`brew bundle add`) new packages to this single target file.

- Good, because there was no interactive prompt; invisible background execution.
- Bad, because `brew bundle add` natively alphabetizes and groups (tap, brew, cask, mas) the entire target file. When `chezmoi diff` compared the native globally-sorted file against the linearly-concatenated Chezmoi template, the resulting diff was unreadable, showing massive line reordering. This proved that Chezmoi templates and native Homebrew commands cannot concurrently manage the layout of the same file.

### Option 6: Dual Raw Target Files with Background Zsh Wrapper

This architecture maintained two independent source files (`personal/Brewfile` and `work/Brewfile`). A custom Zsh wrapper natively executed install/uninstall commands in the terminal and forked a background job to blindly update the user's specific target file.

- Good, because it eliminated Go templating in target files, allowing `chezmoi re-add` to work safely.
- Good, because the sync happened invisibly in the background.
- Bad, because the wrapper added significant complexity and essentially abstracted away a core responsibility of the developer, discouraging manual discipline.

### Option 7: Dual Raw Target Files with Startup Drift Alerts

This is the current architecture. The repository maintains exactly two independent source files (`personal/Brewfile` and `work/Brewfile`). The user is expected to manually run `brew bundle add/remove` after modifying packages on their OS. If they forget, `.zshrc` explicitly runs `brew bundle check` and `brew bundle cleanup` during terminal startup to detect OS-vs-Brewfile drift, rendering a yellow warning identical to `chezmoi status`.

- Good, because it forces the user into the good habit of treating package dependencies identically to file dependencies (manual reconciliation).
- Good, because the codebase remains entirely free of fragile wrapper functions.
- Good, because cross-machine drift is natively surfaced.
- Bad, because Homebrew checks are significantly slower than Chezmoi checks, adding a ~1-2 second penalty to terminal initialization.

## More Information

- [Homebrew bundle subcommand](https://docs.brew.sh/Manpage#bundle-subcommand)

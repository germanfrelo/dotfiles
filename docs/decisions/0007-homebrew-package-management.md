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
- Option 6: Dual Raw Target Files with Automated Sync

## Decision Outcome

Chosen option: "Option 6: Dual Raw Target Files with Automated Sync", because it elegantly solves the "Common vs Specific" package problem while safely automating both additions and subtractions, and it requires absolutely zero Go templating. This ensures `brew bundle add` and `chezmoi re-add` can safely operate on the files without destroying conditional logic.

### Consequences

- Good, because the user can just type `brew install <pkg>` and the Zsh wrapper handles appending it to the target Brewfile in the background.
- Good, because `chezmoi re-add` works flawlessly since the Brewfiles contain zero Go templating logic to destroy.
- Good, because cross-machine drift is natively alerted via `chezmoi status` hash changes when sibling files update remotely.
- Bad, because pulling common packages from another machine requires manually copy-pasting lines between two files when alerted, rather than auto-resolving.

### Confirmation

The workflow can be confirmed by pulling remote changes that affect an ignored Brewfile; running `chezmoi diff` will explicitly show the script's hash changing, proving the native alert system works. Furthermore, running `brew bundle cleanup --install` interactively via `chezmoi apply` successfully prompts before removing unlisted packages.

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

### Option 6: Dual Raw Target Files with Automated Sync

This architecture maintains exactly two independent source files: `personal/Brewfile` and `work/Brewfile`. A custom Zsh wrapper natively executes install/uninstall commands in the terminal and forks a background job to blindly update the user's specific target file. The `run_onchange_after_apply-target-brewfile-to-machine.sh.tmpl` script automatically triggers when `chezmoi apply` is executed and either source Brewfile hash changes.

- Good, because it eliminates Go templating in target files, allowing `chezmoi re-add` to work safely.
- Good, because `chezmoi diff` natively surfaces cross-machine drift via explicit hash changes.
- Good, because it leverages `brew bundle cleanup --install` seamlessly connected to standard input, gracefully handling uninstalls without crashing.

## More Information

- [Homebrew bundle subcommand](https://docs.brew.sh/Manpage#bundle-subcommand)

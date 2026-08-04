# dotfiles

My personal [dotfiles](https://dotfiles.github.io/), managed with [chezmoi](https://www.chezmoi.io/).

## Overview

The [`home/`](/home/) directory is the source directory where the actual dotfiles live.

An index of all files tracked in this directory is maintained in [`MANAGED.txt`](/MANAGED.txt). This is automatically updated via a [pre-commit hook](/.husky/pre-commit), but can also be updated manually via the [`npm run managed`](/package.json) command. Both methods execute [`scripts/managed.js`](/scripts/managed.js).

Chezmoi control files (such as [`.chezmoiignore`](/home/.chezmoiignore) and [`.chezmoi.toml.tmpl`](/home/.chezmoi.toml.tmpl)) and setup scripts (under [`.chezmoiscripts/`](/home/.chezmoiscripts/)) are not copied to the home directory.

Additionally, this directory handles system bootstrapping. A dedicated macOS setup script ([`run_once_before_install-packages-darwin.sh.tmpl`](/home/.chezmoiscripts/darwin/run_once_before_install-packages-darwin.sh.tmpl)) automatically installs Homebrew and all required system packages _before_ deploying any dotfiles. It acts as the single source of truth for macOS packages and automatically re-runs whenever the package list changes.

## Installation

To apply these dotfiles to your machine, follow the chezmoi quick-start guide for [a new machine](https://www.chezmoi.io/quick-start/#set-up-a-new-machine-with-a-single-command) or [an existing machine](https://www.chezmoi.io/quick-start/#using-chezmoi-across-multiple-machines).

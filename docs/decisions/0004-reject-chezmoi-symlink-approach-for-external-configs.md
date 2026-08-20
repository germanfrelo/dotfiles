---
status: accepted
date: 2026-08-01
---

# Reject chezmoi's symlink approach for externally modified configuration files

## Context and Problem Statement

Some configuration files tracked in this repository (such as VS Code settings, Antigravity settings, or Powerlevel10k) are actively mutated by those programs. The [chezmoi documentation](https://www.chezmoi.io/user-guide/manage-different-types-of-file/#handle-configuration-files-which-are-externally-modified) warns that running `chezmoi apply` blindly will overwrite and lose any modifications made by these external programs.

To solve this, chezmoi proposes a "symlink approach": replacing the live configuration file on the target machine with a symbolic link pointing directly back to the file inside the chezmoi source directory (which is under version control). When the external program modifies its configuration, it writes directly into the Git repository.

The question is whether to adopt this symlink approach to prevent accidental overwrites, or stick to the current workflow of snapshotting live files manually.

## Considered Options

- **Adopt the symlink approach** for all externally modified files.
- **Keep the current workflow**: snapshotting live files manually via `chezmoi status`, `chezmoi diff`, and `chezmoi re-add`.

## Decision Outcome

Chosen option: **Keep the current workflow.**

## Evidence / Rationale

- **The atomic write problem:** Many modern applications (including Electron apps like VS Code) use atomic writes to save configuration files—they write to a temporary file and then `mv` it over the target. This completely destroys symlinks, replacing them with a regular file and silently breaking the link to the chezmoi source directory.
- **Git working tree pollution (Crucial Issue):** Symlinking live configs couples the Git working tree directly to live application state. Every time a setting is changed in the UI, an unstaged modification appears in the dotfiles repository. This creates a highly destructive risk: running common Git commands like `git reset --hard` or checking out branches while working on the dotfiles repo could instantly and irreversibly wipe out live application settings.
- **Setup complexity:** Implementing this approach requires running manual shell commands to configure the symlinks on every new machine, introducing a high likelihood of human error or forgetfulness.
- **Redundancy with current safeguards:** The primary benefit of the symlink approach is avoiding silent data loss during a blind `chezmoi apply`. However, this is a solved problem in my architecture. A custom check in [`home/private_dot_config/zsh/dot_zshrc`](/home/private_dot_config/zsh/dot_zshrc) explicitly runs `chezmoi status` once per top-level shell, notifying of any drift the moment a terminal is opened. Because `chezmoi apply` is never run blindly, the risk of accidental overwrites is heavily mitigated.

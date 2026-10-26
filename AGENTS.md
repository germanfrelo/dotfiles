# dotfiles — Agent Instructions

User's dotfiles across multiple macOS machines, managed with chezmoi. See [README.md](/README.md) for repository overview and bootstrapping guides.

## Source paths

This dotfiles repository **deviates from chezmoi's default locations**:

- The **source directory** is **_not_ `~/.local/share/chezmoi`**.
- The **root of the source state** is **_not_ the root of the source directory**, but the subdirectory `home/` (configured in `.chezmoiroot`).

When **referring or dynamically resolving the source paths**:

- **Source directory** (this repository path): `dirname "$(chezmoi source-path)"`.
- **Root of the source state** (the root directory of the managed dotfiles): `chezmoi source-path`.

## Guardrails

- **Read-only commands (allowed):** `diff`, `status`, `cat`, `managed`, `unmanaged`, `ignored`, `data`, `doctor`, `execute-template`. Use `chezmoi diff --use-builtin-diff` in the terminal because default `chezmoi diff` opens VS Code without stdout.
- **State-modifying commands (never execute):** `add`, `apply`, `forget`, `merge`, `merge-all`, `re-add`, `update`. When suggesting any state-modifying command, provide the preview (`--dry-run --verbose` or `-nv`) first, followed by the execution command (`--verbose` or `-v`).
- **Destination file protection:** Never edit destination files directly; edit only source files under `home/`, then verify with `chezmoi diff --use-builtin-diff`.
- **Scaffolding prohibition:** Never scaffold new configurations from scratch in source or destination directories; instruct the user to create the destination file and run `chezmoi add <target-path>`.
- **Secrets security:** Author new `private_` files directly in the source tree as templates using `onepasswordRead` (never paste raw secrets). If an existing destination file was edited directly, verify the source template does not use `onepassword*` before suggesting `chezmoi re-add`; if it does use `onepassword*`, abort and ask the user to re-template manually.
- **Enforced absent files:** Follow the [Enforcing Absent Files Runbook](/docs/runbooks/enforcing-absent-files.md) to declare, verify, or revert absent dotfiles.

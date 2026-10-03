# dotfiles — Agent Instructions

> My dotfiles across multiple machines, managed with [chezmoi](https://www.chezmoi.io/).

**Note:** For the full overview of this repository, read the `README.md`.

## Source structure

- **Source directory:** not `~/.local/share/chezmoi`; resolve dynamically in scripts and CLI using `$(chezmoi source-path)`.
- **Source state root:** the `home/` subdirectory of this repository.

## Pre-operation workflow

**Invariant:** `chezmoi unmanaged` MUST always return empty. If violated, stop and surface the unmanaged files to the user.

- **Always run** `chezmoi status`, `chezmoi unmanaged`, and `chezmoi ignored` before/after operations, and before committing.
- **Never fabricate changes** if `chezmoi status` is empty.

## Applying changes

**For existing managed files:** Never edit target files — always edit the source files, then run `chezmoi diff --use-builtin-diff` to check the changes. You must **NEVER** run `chezmoi apply` or suggest the user run it, to prevent target data loss.

**Creating new dotfiles:** You are banned from scaffolding or creating new configurations from scratch in the destination and source directories. If a new configuration is needed, you must instruct the user to create the file in their destination directory and run chezmoi add <target-path> themselves.

**Exception for new secrets:** When creating a new `private_` file, always author it directly in the source tree as a template using `onepasswordRead` — never paste secret values directly into a target file. If an existing target file was edited directly and must be preserved, use `chezmoi re-add` instead — but if the source template calls any `onepassword*` function, abort and ask the user to re-template manually, to avoid rendering secrets into the source.

## chezmoi Commands and Permissions

### State-modifying commands (You CANNOT run; you CAN suggest)

`add`, `apply`, `forget`, `merge-all`, `merge`, `re-add`, `update`

You must **NEVER** run these state-modifying commands yourself to prevent data loss. You may only _suggest_ the user run them. When suggesting, always provide a preview command (`--dry-run --verbose`) first, followed by the execution command (`--verbose`).

### Read-only commands (You CAN run)

`diff`, `status`, `cat`, `managed`, `unmanaged`, `data`, `doctor`, `execute-template`, `edit`

You are free to execute these commands. Always include the `--verbose` flag.

### Diff in terminal

Use `chezmoi diff --use-builtin-diff` instead of `chezmoi diff` — the configured `diff_tool` is VS Code, so `chezmoi diff` produces no terminal output.

## `remove_` targets

Files enforced absent are managed via `remove_` source files. (See "Enforced absent" in `MANAGED.txt`).

- **To add:** Write a decision record in `docs/decisions/`. Create `home/[path/]remove_dot_<name>` containing a comment linking to the decision. Update `.chezmoiignore` if needed. Commit.
- **To revert:** Mark decision superseded. `trash` the `remove_` file. Re-manage with `chezmoi add <target>` or create source manually. Update `.chezmoiignore`. Commit.

_(Note: Let the user handle `chezmoi apply` for these changes.)_

## Git commit conventions

The **commit scope** is required in this repository. Because this repository manages configurations for many distinct tools, use your best judgement based on the following guiding principles rather than a strict whitelist. **You are completely free to invent new scopes not listed in these examples if they better describe the change.**

_Tip: You may run `git log --oneline -15` to glance at recently used scopes for context. However, these explicit written rules always take precedence over any formatting anomalies or deprecated conventions found in the repository history._

1. **Consider the target tool:** When a commit predominantly configures a specific application, the scope is often just that application's name (e.g., `vscode`, `zsh`, `git`, `homebrew`, etc.).
2. **Abstract when necessary:** When a change spans multiple tools cohesively (e.g., a system-wide font update) or applies to repository infrastructure (e.g., dependency bumps, AI instructions), derive a thematic or structural scope that best describes the logical outcome (e.g., `typography`, `deps`, `ai`, etc.).
3. **Prioritize clarity over convention:** Never force a change into a bucket if it doesn't fit naturally. For edge cases, invent whatever scope makes the git history most readable to a human.

### Repository path resolution

When writing or modifying scripts (Bash, Node.js, Python, etc.) that need to reference or access my local repositories directory, you MUST NOT hardcode absolute or home-relative paths. NEVER use specific path strings like `~/path/to/repos`, `$HOME/path/to/repos`, or Node's `os.homedir()`.

Instead, you must strictly use one of the following dynamic resolution methods:

1. **Relative paths (preferred):** If the script lives inside a repository and needs to access sibling repositories, calculate the path relative to the script's execution location (e.g., navigating up the directory tree using `path.resolve(__dirname, '../../')` in Node.js, or `$(cd "$(dirname "$0")/../.." && pwd)` in Bash).
2. **Environment variable fallback:** If using relative paths is impossible or the script runs globally, read the `$REPOS_DIR` environment variable. Because environment variables can be missing in certain execution contexts (like GUI apps, Cron, or CI), you must always provide a mathematical relative fallback if applicable (e.g., `const REPOS_DIR = process.env.REPOS_DIR || path.resolve(__dirname, '../../');`).

[Reference: ADR 0005](/docs/decisions/0005-repos-directory-path-architecture.md)

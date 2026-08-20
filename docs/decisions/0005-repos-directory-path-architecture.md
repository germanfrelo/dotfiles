---
status: accepted
date: 2026-08-20
---

# Repos directory path architecture

## Context and problem statement

Scripts, dotfiles, and system configurations frequently need to interact with the local repositories directory. Hardcoding local absolute paths across different shell scripts and Node.js tools creates a brittle architecture. If the physical folder is ever moved, it requires an exhaustive global search and updates across multiple repositories to prevent system failure.

I needed a standardized, decoupled architecture for resolving the path to my source code repositories.

## Decision drivers

- The configuration must survive even if `chezmoi` is not installed or evaluated.
- The path must be accessible to pure shell scripts, GUI applications, and Node.js tooling.
- Cross-repository scripts should not rely on global machine configurations if possible.

## Considered options

1. Hardcoding paths everywhere.
2. Relying entirely on Chezmoi templating (e.g., `{{ .repos_dir }}`).
3. A hybrid architecture using environment variables and relative path math.

## Decision outcome

Chosen option: **Option 3 (Hybrid architecture)**, because it provides bulletproof fallbacks and completely decouples external tooling from specific machine configurations.

### 1. The core definition (the source of truth)

The physical string of the repository directory will strictly exist in only **three** specific files in the `dotfiles` repository:

1. `.chezmoi.toml.tmpl`: Used for Chezmoi's `source_dir`.
2. `.zshrc`: Used as the pure shell fallback logic.
3. `.chezmoiscripts/darwin/run_once_after_clone-github-repos.sh`: Used for the initial machine bootstrap.

### 2. Shell injection

In `.zshrc`, the path is exported dynamically, with the hardcoded string acting solely as a fallback if the variable is not already provided by the OS:

```sh
export REPOS_DIR="${REPOS_DIR:-$HOME/path/to/repos}"
```

### 3. Sibling repository tooling

Any scripts written in other repositories must **never** hardcode the root path. They must resolve the directory dynamically by either reading `$REPOS_DIR` or calculating the relative path mathematically (e.g., `__dirname + '../../'`).

## Consequences

- **Positive:** Repositories can be executed in CI environments or on different machines without path failures.
- **Positive:** Moving the physical folder in the future only requires updating 3 predictable files in `dotfiles`.
- **Negative:** None.

---
status: accepted
date: 2026-05-28
---

# Remove .zprofile — zsh4humans handles Homebrew environment automatically

## Context and Problem Statement

macOS (Apple Silicon) installs Homebrew at `/opt/homebrew`. The standard Homebrew post-install
instruction is to add `eval "$(/opt/homebrew/bin/brew shellenv)"` to `~/.zprofile`. This sets
`HOMEBREW_PREFIX`, `HOMEBREW_CELLAR`, `HOMEBREW_REPOSITORY`, and adds Homebrew's directories to
`PATH`, `MANPATH`, `INFOPATH`, and `fpath` (for zsh completions).

zsh4humans (z4h) v5 is the shell framework in use. Its README explicitly warns:
["Do not create \[`.zprofile`\] unless you are absolutely certain you need it."](https://github.com/romkatv/zsh4humans/blob/v5/README.md#additional-zsh-startup-files)

The question is whether `eval "$(brew shellenv)"` is still necessary when using z4h.

## Considered Options

- Keep `eval "$(/opt/homebrew/bin/brew shellenv)"` in `.zprofile`
- Remove `.zprofile` entirely and rely on z4h to set up the Homebrew environment

## Decision Outcome

Chosen option: **Remove `.zprofile` entirely**, because z4h v5 `main.zsh` replicates everything
`brew shellenv` sets, making the explicit call redundant.

## Evidence

### What `brew shellenv` sets

From the [Homebrew `shellenv` manpage](https://raw.githubusercontent.com/Homebrew/brew/refs/heads/main/docs/Manpage.md):

| Variable / path array | Effect                                                                                                                                                                                                               |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `HOMEBREW_PREFIX`     | Points to the Homebrew installation root                                                                                                                                                                             |
| `HOMEBREW_CELLAR`     | Points to the Cellar directory                                                                                                                                                                                       |
| `HOMEBREW_REPOSITORY` | Points to the Homebrew repository                                                                                                                                                                                    |
| `PATH`                | Prepends `$HOMEBREW_PREFIX/bin` and `$HOMEBREW_PREFIX/sbin`                                                                                                                                                          |
| `MANPATH`             | Prepends `$HOMEBREW_PREFIX/share/man`                                                                                                                                                                                |
| `INFOPATH`            | Prepends `$HOMEBREW_PREFIX/share/info`                                                                                                                                                                               |
| `fpath`               | Prepends `$HOMEBREW_PREFIX/share/zsh/site-functions` (required for zsh completions — see [Homebrew Shell Completion docs](https://raw.githubusercontent.com/Homebrew/brew/refs/heads/main/docs/Shell-Completion.md)) |

### What z4h does instead

From [`main.zsh` in the zsh4humans v5 branch](https://github.com/romkatv/zsh4humans/blob/v5/main.zsh):

**1. Detects Homebrew and exports the three env vars:**

```zsh
function -z4h-init-homebrew() {
  (( ARGC )) || return 0
  local dir=${1:h:h}
  export HOMEBREW_PREFIX=$dir
  export HOMEBREW_CELLAR=$dir/Cellar
  if [[ -e $dir/Homebrew/Library ]]; then
    export HOMEBREW_REPOSITORY=$dir/Homebrew
  else
    export HOMEBREW_REPOSITORY=$dir
  fi
}

# On macOS, checks /opt/homebrew (Apple Silicon) then /usr/local (Intel):
[[ -z $HOMEBREW_PREFIX ]] && -z4h-init-homebrew {/opt/homebrew,/usr/local}/bin/brew(N)
```

**2. Extends PATH, MANPATH, and INFOPATH:**

```zsh
# PATH
{…,${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin},${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin},…}(-/N)
# MANPATH
{${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/man},…}(-/N)
# INFOPATH
{${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/info},…}(-/N)
```

**3. Extends fpath for zsh completions (both dynamic and hardcoded fallback):**

```zsh
fpath=(
  …
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/zsh/site-functions}(-/N)
  /opt/homebrew/share/zsh/site-functions(-/N)
  …
)
```

This also matches what the [zsh4humans tips.md](https://github.com/romkatv/zsh4humans/blob/v5/tips.md#homebrew)
documents: "`HOMEBREW_PREFIX` being automatically set" by z4h.

### Full parity table

| `brew shellenv` output    | Handled by z4h v5 |
| ------------------------- | ----------------- |
| `HOMEBREW_PREFIX`         | ✅                |
| `HOMEBREW_CELLAR`         | ✅                |
| `HOMEBREW_REPOSITORY`     | ✅                |
| `PATH`                    | ✅                |
| `MANPATH`                 | ✅                |
| `INFOPATH`                | ✅                |
| `fpath` (zsh completions) | ✅                |

### Confirmation from the z4h author

The z4h author (romkatv) confirmed this directly in
[zsh4humans issue #351](https://github.com/romkatv/zsh4humans/issues/351) (opened by the dotfiles
owner):

> "Yes, the brew line is no longer needed."

## Consequences

- `.zprofile` is entirely absent from the dotfiles.
- chezmoi [`remove_` source files](https://www.chezmoi.io/reference/source-state-attributes/) are
  used to enforce this: `home/private_dot_config/zsh/remove_dot_zprofile` (guards `$ZDOTDIR/.zprofile`)
  and `home/remove_dot_zprofile` (guards `~/.zprofile`). chezmoi deletes the target files on every
  `chezmoi apply`, preventing accidental re-creation by any tool or agent.
- If z4h is ever replaced or removed, the Homebrew environment setup must be restored manually
  (e.g. by re-adding `eval "$(brew shellenv)"` to `~/.zshrc` or `~/.zprofile`).

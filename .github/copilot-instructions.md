# Dotfiles — Agent Instructions

<!-- cspell:ignore chezmoi chezmoiroot chezmoiscripts tmpl onepasswordRead darwin heredocs -->

Chezmoi-managed dotfiles for macOS (Apple Silicon). See [README](../README.md) and [docs/chezmoi.md](../docs/chezmoi.md) for setup details.

## Source structure

`.chezmoiroot = home` — chezmoi's source root is `home/`. File naming encodes target path and behaviour:

- `dot_` prefix → target filename starts with `.` (`dot_zshrc` → `.zshrc`)
- `private_` prefix → file contains secrets; chezmoi treats it as sensitive
- `.tmpl` extension → Go template, rendered at apply time
- `run_once_before_<name>.sh.tmpl` → runs once (before dotfile apply), re-runs when rendered content changes

Prefixes stack: `private_dot_config` → `~/.config/` (private). Combine with `.tmpl` for templating: `private_dot_config.tmpl`.

If a `run_once` script fails, fix the script and re-run `chezmoi apply`; chezmoi retries because state is keyed on the rendered content hash.

Never modify live files under `~/.config/` directly (reading them is fine). Always edit the source under `home/`. Before suggesting `chezmoi apply`, always suggest `chezmoi diff` first so the user can review the rendered diff (except for the git config template, which will hang if `op` is not authenticated).

## Templates

Uses Go's `text/template` with chezmoi's [template functions](https://www.chezmoi.io/reference/templates/functions/). Data variable `machine_type` is always either `"personal"` or `"work"` — no default branch is needed. Use it to branch machine-specific content:

```
{{- if eq .machine_type "personal" }}
…personal content…
{{- end }}
```

**Heredoc pitfall (critical):** Inside `<<'EOF'` heredocs, never use `-}}` (right whitespace trim). It strips the trailing newline and merges the next line, breaking the heredoc. Use `{{- if … }}` (left trim only) or `{{ if … }}` (no trim).

## Git config template

`home/private_dot_config/private_git/private_config.tmpl` renders to `~/.config/git/config`. It fetches the SSH signing key from 1Password at render time via `onepasswordRead`. Ensure `op` is authenticated (`op signin`) before running any chezmoi command that touches this file. If `op` is not authenticated, `chezmoi diff`, `chezmoi apply`, and `chezmoi cat` on that file will hang — read `~/.config/git/config` directly instead.

## Homebrew packages

`home/.chezmoiscripts/darwin/run_once_before_install-packages-darwin.sh.tmpl` is the single source of truth for all Homebrew packages. `brew bundle` is never destructive — removing a package from the template does **not** uninstall it; instruct the user to run `brew uninstall <pkg>` manually first. Do not run it automatically.

## Commits

Follow Conventional Commits (`type: Description`). Do not use a scope in this repo — every change is implicitly dotfiles/chezmoi. Subject in imperative mood, ≤ 50 characters. For breaking changes, use `type!: Description` and add a `BREAKING CHANGE:` footer. Commits that only change whitespace, indentation, or line wrapping (no semantic change) must be added to `.git-blame-ignore-revs` using the full commit SHA.

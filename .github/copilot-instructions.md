# Dotfiles — Agent Instructions

Chezmoi-managed dotfiles for macOS (Apple Silicon). See [README](../README.md) and [docs/chezmoi.md](../docs/chezmoi.md) for setup details.

## Source structure

`.chezmoiroot = home` — chezmoi's source root is `home/`. File naming encodes target path and behaviour:

- `dot_` prefix → target filename starts with `.` (`dot_zshrc` → `.zshrc`)
- `private_` prefix → file contains secrets; chezmoi treats it as sensitive
- `.tmpl` extension → Go template, rendered at apply time
- `run_once_before_<name>.sh.tmpl` → runs once (before dotfile apply), re-runs when rendered content changes

Never edit live files under `~/.config/` directly. Always edit the source under `home/`, then run `chezmoi apply`.

## Templates

Uses Go's `text/template` with chezmoi's [template functions](https://www.chezmoi.io/reference/templates/functions/). Data variable `machine_type` is either `"personal"` or `"work"` — use it to branch machine-specific content:

```
{{- if eq .machine_type "personal" }}
…personal content…
{{- end }}
```

**Heredoc pitfall (critical):** Inside `<<'EOF'` heredocs, never use `-}}` (right whitespace trim). It strips the trailing newline and merges the next line, breaking the heredoc. Use `{{- if … }}` (left trim only) or `{{ if … }}` (no trim).

## Git config template

`home/private_dot_config/private_git/private_config.tmpl` renders to `~/.config/git/config`. It fetches the SSH signing key from 1Password at render time via `onepasswordRead`. If `op` is not authenticated, `chezmoi diff`, `chezmoi apply`, and `chezmoi cat` on that file will hang — read `~/.config/git/config` directly instead.

## Homebrew packages

`home/.chezmoiscripts/darwin/run_once_before_install-packages-darwin.sh.tmpl` is the single source of truth for all Homebrew packages. `brew bundle` is never destructive — removing a package from the template does **not** uninstall it; `brew uninstall` manually first.

## Commits

Follow Conventional Commits (`type: Description`). Do not use a scope in this repo — every change is implicitly dotfiles/chezmoi. Subject in imperative mood, ≤ 50 characters. Formatting-only commits must be added to `.git-blame-ignore-revs`.

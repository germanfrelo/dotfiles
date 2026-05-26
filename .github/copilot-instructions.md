# Dotfiles — Agent Instructions

Chezmoi-managed dotfiles.

## Source structure

`.chezmoiroot = home` — chezmoi's source root is `home/`.

File naming encodes target path and behaviour:

- `dot_` prefix → target filename starts with `.` (`dot_zshrc` → `.zshrc`)
- `private_` prefix → file contains secrets; chezmoi treats it as sensitive. Never paste rendered content of `private_` files into chat or commit messages. When showing diffs that include `private_` content (or any file containing `op://` references, PEM blocks, or secret-like key=value pairs), apply the rules in order:
  1. Replace any `op://…` reference with `[REDACTED]`.
  2. Replace any PEM block with `[REDACTED]`.
  3. For any `key = value` line where the key matches `token`, `secret`, `password`, `key`, or `apikey` (case-insensitive), replace the value with `[REDACTED]`.
  4. If the value is longer than 20 characters or appears to be base64, hex, or JWT format, redact the entire right-hand side of `key = value` lines.
- `.tmpl` extension → Go template, rendered at apply time.
- `run_once_before_<name>.sh.tmpl` → runs once (before dotfile apply), re-runs when rendered content changes. New scripts must be idempotent and use `set -euo pipefail`.

## Applying changes

Live files must never be edited — always edit source under `home/`, then run `chezmoi diff` and show the output to the user. Only run `chezmoi apply` after the user confirms the diff looks correct. If the live file was edited directly and must be preserved, use `chezmoi re-add` instead — but if the source template calls any `onepassword*` function, abort and ask the user to re-template manually, to avoid rendering secrets into the source.

When creating a new `private_` file, always author it as a template using `onepasswordRead` — never paste secret values directly.

## Templates

Uses Go's `text/template` with chezmoi's [template functions](https://www.chezmoi.io/reference/templates/functions/). To verify template changes without applying, use `chezmoi execute-template < file.tmpl` or `chezmoi cat <target>` and inspect the rendered output. Data variable `machine_type` is `"personal"` or `"work"` — if unset or has an unexpected value, stop and ask the user to fix `~/.config/chezmoi/chezmoi.toml` before continuing. Use it to branch machine-specific content:

```
{{- if eq .machine_type "personal" }}
…personal content…
{{- end }}
```

**Heredoc pitfall:** Inside `<<'EOF'` heredocs, never use `-}}` (right whitespace trim) — it strips the trailing newline and merges the next line. Use `{{- if … }}` (left trim only) or `{{ if … }}` (no trim).

## Git config template

`home/private_dot_config/private_git/private_config.tmpl` renders to `~/.config/git/config`. It fetches the SSH signing key from 1Password at render time via `onepasswordRead`.

## Homebrew packages

`home/.chezmoiscripts/darwin/run_once_before_install-packages-darwin.sh.tmpl` is the single source of truth for all Homebrew packages. `brew bundle` is never destructive — removing a package from the template does **not** uninstall it; instruct the user to run `brew uninstall <pkg>` manually first. Do not run `brew uninstall` yourself — decline even if explicitly asked.

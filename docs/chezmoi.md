# chezmoi

Cheat sheet.

## Quick reference

> **Flag conventions:** Always use `--verbose` with every command. For state-modifying commands (`apply`, `add`, `re-add`, `update`, `forget`, `merge`, `merge-all`), run `--dry-run --verbose` first to preview, then the same command with `--verbose` only to execute.

| Situation                                  | Command                                            |
| ------------------------------------------ | -------------------------------------------------- |
| Add a file to management                   | `chezmoi add ~/.file`                              |
| Edit a managed file                        | `chezmoi edit ~/.file`                             |
| Edit and apply on quit                     | `chezmoi edit --apply ~/.file`                     |
| Preview all pending changes                | `chezmoi diff`                                     |
| Preview changes for one file               | `chezmoi diff ~/.file`                             |
| Apply all pending changes                  | `chezmoi apply`                                    |
| Apply one file                             | `chezmoi apply ~/.file`                            |
| Template is correct, live file drifted     | `chezmoi apply ~/.file`                            |
| Live file is correct, template is outdated | `chezmoi re-add ~/.file` (non-template files only) |
| Render template without writing            | `chezmoi cat ~/.file`                              |
| Test a template expression                 | `chezmoi execute-template '{{ expr }}'`            |
| Quick status overview                      | `chezmoi status`                                   |
| Pull remote changes and apply              | `chezmoi update`                                   |
| Open a shell in the source directory       | `chezmoi cd`                                       |
| Run git in the source directory            | `chezmoi git -- <args>`                            |
| List managed files                         | `chezmoi managed`                                  |
| List unmanaged files                       | `chezmoi unmanaged`                                |
| Show computed template data                | `chezmoi data`                                     |
| Check for common problems                  | `chezmoi doctor`                                   |
| Merge conflicts between source and live    | `chezmoi merge ~/.file`                            |
| Merge all conflicted files                 | `chezmoi merge-all`                                |
| Stop managing a file                       | `chezmoi forget ~/.file`                           |

## Core commands

### Occasional

#### [`cat`](https://chezmoi.io/reference/commands/cat/)

Print the target state contents of a file to stdout without writing anything to disk. Useful for previewing template output.

```sh
chezmoi cat --verbose "$XDG_CONFIG_HOME/git/config"
```

#### [`re-add`](https://chezmoi.io/reference/commands/re-add/)

Pull the current destination state back into the source state for non-template files. Does **not** overwrite existing templates — use `chezmoi add --force` to replace a template.

```sh
chezmoi re-add --dry-run --verbose "$ZDOTDIR/.zshrc"  # preview
chezmoi re-add --verbose "$ZDOTDIR/.zshrc"            # execute
chezmoi re-add --dry-run --verbose                    # preview all modified
chezmoi re-add --verbose                              # re-add all modified files
```

#### [`merge`](https://chezmoi.io/reference/commands/merge/)

Three-way merge between the destination state, target state, and source state. Default tool: `vimdiff`.

```sh
chezmoi merge --verbose "$ZDOTDIR/.zshrc"
```

#### [`merge-all`](https://chezmoi.io/reference/commands/merge-all/)

Run `chezmoi merge` for every file whose actual state does not match the target state.

```sh
chezmoi merge-all --verbose
```

#### [`managed`](https://chezmoi.io/reference/commands/managed/)

List all entries managed by chezmoi.

```sh
chezmoi managed --verbose
chezmoi managed --verbose --include=files
chezmoi managed --verbose -i files ~/.config
```

#### [`unmanaged`](https://chezmoi.io/reference/commands/unmanaged/)

List all files in the home directory not managed by chezmoi.

```sh
chezmoi unmanaged --verbose
chezmoi unmanaged --verbose ~/.config
```

#### [`data`](https://chezmoi.io/reference/commands/data/)

Write the computed [template data](https://chezmoi.io/reference/templates/variables/) to stdout. Useful for inspecting what variables are available in templates.

```sh
chezmoi data --verbose
chezmoi data --verbose --format=yaml
```

#### [`doctor`](https://chezmoi.io/reference/commands/doctor/)

Check for common problems. Run this first when something unexpected happens.

```sh
chezmoi doctor --verbose
```

#### [`execute-template`](https://chezmoi.io/reference/commands/execute-template/)

Execute a template for testing without writing to disk. Pass a literal expression as an argument, or pipe a file.

```sh
chezmoi execute-template --verbose '{{ .chezmoi.os }}'
chezmoi execute-template --verbose '{{ .chezmoi.hostname }}'
chezmoi execute-template --verbose < "$(chezmoi source-path)/dot_zshrc.tmpl"
```

#### [`forget`](https://chezmoi.io/reference/commands/forget/)

Stop managing a file — removes it from the source state only. The file remains in your home directory unchanged. Alias: `unmanage`.

```sh
chezmoi forget --dry-run --verbose ~/.file  # preview
chezmoi forget --verbose ~/.file            # execute
```

## Workflows

### Edit a managed file

Three approaches, in recommended order.

#### Option 1 — `chezmoi edit` (preferred)

Opens the source file in your editor with the correct filename for syntax highlighting. Handles encrypted files transparently.

```sh
chezmoi edit --verbose "$ZDOTDIR/.zshrc"                         # edit only
chezmoi edit --apply --verbose "$ZDOTDIR/.zshrc"                 # edit and apply on quit
chezmoi edit --verbose                                           # open entire source directory
```

#### Option 2 — `chezmoi cd`

Opens a shell in the source directory. Edit files directly, then diff and apply manually.

```sh
chezmoi cd
# edit files...
chezmoi diff --verbose
chezmoi apply --dry-run --verbose  # preview
chezmoi apply --verbose            # execute
exit
```

#### Option 3 — Edit the live file directly

If you edited `"$ZDOTDIR/.zshrc"` outside chezmoi, the change survives until the next `chezmoi apply`, which will prompt you to resolve the conflict. Pull the edit back into the source state with:

```sh
chezmoi re-add --dry-run --verbose "$ZDOTDIR/.zshrc"  # preview (plain files only)
chezmoi re-add --verbose "$ZDOTDIR/.zshrc"            # execute (plain files only)
chezmoi merge --verbose "$ZDOTDIR/.zshrc"             # when both source and live have changes to keep
```

`re-add` does **not** overwrite templates. If the source file is a template, modify the template logic manually.

### VS Code managed files

`settings.json`, `prompts/*.instructions.md`, and `snippets/*.json` are tracked by chezmoi as a git-tracked backup. VS Code Settings Sync is the primary source of truth and syncs these files automatically across machines — all categories remain enabled. chezmoi captures snapshots in the reverse direction (live → source) via `re-add`, never the other way in normal use. See [ADR 0002](/docs/decisions/0002-vscode-settings-sync-coexistence.md) for the rationale.

#### Day-to-day (Settings Sync updates a file)

Settings Sync pulls a change from the cloud → the chezmoi-drift LaunchAgent detects drift, or `chezmoi status` shows the file as `MM`:

```sh
chezmoi diff --use-builtin-diff ~/Library/Application\ Support/Code/User/settings.json  # review
chezmoi re-add --dry-run --verbose ~/Library/Application\ Support/Code/User/settings.json  # preview
chezmoi re-add --verbose ~/Library/Application\ Support/Code/User/settings.json  # update backup
chezmoi git add . && chezmoi git -- commit -m "chore: ..."
```

Substitute the relevant path for prompts (`User/prompts/<file>.instructions.md`) and snippets (`User/snippets/<file>.json`).

#### `chezmoi apply` conflict rule

If `chezmoi apply` prompts about a VS Code file (the live file was modified since chezmoi last wrote it), always choose **keep destination** — Settings Sync's version wins. Then immediately:

```sh
chezmoi re-add --verbose ~/Library/Application\ Support/Code/User/<file>
chezmoi git add . && chezmoi git -- commit -m "chore: ..."
```

#### New machine setup (with Settings Sync)

```sh
# 1. Install tooling and initialise chezmoi
chezmoi init git@github.com:germanfrelo/dotfiles.git
chezmoi apply --verbose  # writes VS Code files from backup as a baseline

# 2. Open VS Code and sign in — Settings Sync runs with all categories enabled
#    If VS Code shows a "Local vs Cloud" conflict dialog: choose Accept Cloud

# 3. After Settings Sync completes, check for drift
chezmoi diff --use-builtin-diff ~/Library/Application\ Support/Code/User/
# If drift: re-add each changed VS Code file and commit
chezmoi re-add --verbose ~/Library/Application\ Support/Code/User/<file>
chezmoi git add . && chezmoi git -- commit -m "chore: ..."
```

## Template basics

Chezmoi uses Go's [`text/template`](https://pkg.go.dev/text/template) syntax, extended with [sprig](https://masterminds.github.io/sprig/) functions. A file is treated as a template if it has a `.tmpl` suffix.

Full reference: [user-guide/templating](https://chezmoi.io/user-guide/templating/) · [template variables](https://chezmoi.io/reference/templates/variables/)

### Key built-in variables

| Variable             | Example value              | Description                       |
| -------------------- | -------------------------- | --------------------------------- |
| `.chezmoi.os`        | `"darwin"`                 | Operating system (`runtime.GOOS`) |
| `.chezmoi.arch`      | `"arm64"`                  | Architecture (`runtime.GOARCH`)   |
| `.chezmoi.hostname`  | `"my-mac"`                 | Hostname up to the first `.`      |
| `.chezmoi.username`  | `"germanfrelo"`            | Current username                  |
| `.chezmoi.homeDir`   | `"/Users/germanfrelo"`     | Home directory                    |
| `.chezmoi.sourceDir` | `"~/.local/share/chezmoi"` | Source directory path             |

Custom variables from `$XDG_CONFIG_HOME/chezmoi/chezmoi.toml` are available under their key names directly (e.g. `.machine_type`, `.email`). Use `chezmoi data` to see all available variables.

### Conditional syntax

```text
{{ if eq .chezmoi.os "darwin" }}
…macOS content…
{{ else if eq .chezmoi.os "linux" }}
…Linux content…
{{ end }}
```

Combine conditions with `and` / `or`:

```text
{{ if (and (eq .chezmoi.os "linux") (ne .chezmoi.hostname "server")) }}
…{{ end }}
```

Whitespace trimming: `{{-` trims all whitespace (spaces, tabs, newlines) to the left; `-}}` trims to the right.

### Testing templates

```sh
chezmoi execute-template --verbose '{{ .chezmoi.os }}'
chezmoi execute-template --verbose '{{ . | toJson }}'
chezmoi execute-template --verbose < "$(chezmoi source-path)/dot_zshrc.tmpl"
chezmoi cat --verbose "$ZDOTDIR/.zshrc"    # render and show full target output
chezmoi data --verbose                     # inspect all available variables
```

## My notes

Repo-specific notes not covered by the reference above.

### 1Password CLI and `chezmoi diff`

`chezmoi diff` and `chezmoi cat` on `home/private_dot_config/private_git/private_config.tmpl` (git config) hang if the 1Password CLI is not authenticated. Use `cat "$XDG_CONFIG_HOME/git/config"` directly for inspection when 1Password is unavailable.

### Heredoc pitfall in templates

Inside `<<'EOF'` heredocs in shell scripts, never use `-}}` (right whitespace trim) — it strips the trailing newline and merges the next line into the current one. Use `{{- if … }}` (left trim only) or `{{ if … }}` (no trim) instead.

### Homebrew packages

`home/.chezmoiscripts/darwin/run_onchange_before_install-packages-darwin.sh.tmpl` is the single source of truth for all Homebrew packages.

`brew bundle` is intentionally **not destructive** — removing a package from the template does **not** uninstall it. You must run `brew uninstall <pkg>` manually first; the template removal is bookkeeping only.

#### Reconcile installed packages against the template

```sh
# Re-render the template
chezmoi execute-template --verbose < home/.chezmoiscripts/darwin/run_onchange_before_install-packages-darwin.sh.tmpl > /tmp/rendered.sh

# Extract and sort the tracked list
awk '/<<.*BUNDLED_PACKAGES_EOF/{f=1;next} /^BUNDLED_PACKAGES_EOF/{f=0} f && /^(brew|cask|mas)/{gsub(/ #.*/, ""); print}' /tmp/rendered.sh | sort > /tmp/brewfile-template.txt

# Extract and sort the installed list
brew bundle dump --file=/tmp/brewfile-installed-raw.txt --force --no-vscode
grep -E '^(brew |cask |mas )' /tmp/brewfile-installed-raw.txt | sort > /tmp/brewfile-current.txt

# Compare
code --diff /tmp/brewfile-current.txt /tmp/brewfile-template.txt
```

Red (left only) = installed but not tracked → add to template or uninstall manually.
Green (right only) = tracked but not installed → will be installed on next `chezmoi apply`.

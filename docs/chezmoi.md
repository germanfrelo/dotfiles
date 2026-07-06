# chezmoi

The learning pattern:

| Situation                       | Command                          |
| ------------------------------- | -------------------------------- |
| Template correct, live drifted  | `chezmoi apply <file>`           |
| Live correct, template outdated | `chezmoi re-add <file>` → commit |
| Preview before applying         | `chezmoi diff <file>`            |
| Render template without writing | `chezmoi cat <file>`             |

Also note: any tool that auto-modifies a chezmoi-managed file (`git lfs install`, etc.) will have its additions **overwritten on next `chezmoi apply`**. The fix is always: add that tool's install command to a chezmoi run-once script.

## chezmoi reconciliation workflow

### Mental model

- **Source** (repo `home/`) = single source of truth (templates live here)
- **Live** (`~/.config/...`) = generated output from templates
- Direction of truth: **source → live** (never live → source, unless you're adopting a new file)

### Core commands

| Goal                             | Command                               |
| -------------------------------- | ------------------------------------- |
| Preview changes source→live      | `chezmoi diff`                        |
| Preview for one file             | `chezmoi diff ~/.config/git/config`   |
| Apply all pending changes        | `chezmoi apply`                       |
| Apply one file only              | `chezmoi apply ~/.config/git/config`  |
| Render template without applying | `chezmoi cat ~/.config/git/config`    |
| Pull live edits back into source | `chezmoi re-add ~/.config/git/config` |
| Show managed files               | `chezmoi managed`                     |

### Live file diverged from template — how to reconcile

If the live file was manually edited or mutated by a tool:

- **Template is correct** → run `chezmoi apply <file>` to overwrite live with rendered template
- **Live is correct** → run `chezmoi re-add <file>` to pull the live edit back into the source template, then review and commit

### Known constraint: 1Password templates

`chezmoi diff` and `chezmoi cat` on `private_config.tmpl` (git config) hang if 1Password CLI is not authenticated. Use `cat ~/.config/git/config` directly for inspection.

### Pattern: tools that auto-modify chezmoi-managed files

Tools like `git lfs install` append to `~/.config/git/config`. After `chezmoi apply`, those additions are **removed** (chezmoi overwrites the file). Fix: add the tool's install command to the run-once install script so it re-runs after every `chezmoi apply`.

Example: add `git lfs install` to `home/.chezmoiscripts/darwin/run_once_before_install-packages-darwin.sh.tmpl`.

## Homebrew packages reconciliation workflow

### Installing a package and tracking it

1. Add the entry to the template (correct section: common, personal, or work)
2. Run `chezmoi apply` — because the rendered script content changed, chezmoi re-runs it, and `brew bundle` installs the new package
3. Commit the template

### Installing a package without tracking it

1. `brew install <formula>` or `brew install --cask <cask>`
2. Done — it won't be installed on fresh machines and will appear as a red line in future diffs

### Uninstalling a package that is tracked

1. Remove it from the template
2. Manually uninstall it: `brew uninstall <formula>` or `brew uninstall --cask <cask>`
3. Commit the template
4. `chezmoi apply` — the script re-runs with the updated list; `brew bundle` won't reinstall it since it's gone

**Critical:** `brew bundle` is intentionally **not destructive** — it never uninstalls packages on its own, even when they're removed from the Brewfile. You must uninstall manually first; the template removal is just bookkeeping.

### Uninstalling a package that is not tracked

1. `brew uninstall <formula>` or `brew uninstall --cask <cask>`
2. Done

### The periodic reconciliation workflow

Whenever you've done ad-hoc installs and want to sync with the template, run the comparison you just set up:

```bash
# Re-render template
chezmoi execute-template < home/.chezmoiscripts/darwin/run_once_before_install-packages-darwin.sh.tmpl > /tmp/rendered.sh

# Rebuild template list (sorted, comments stripped)
awk '/<<.*BUNDLED_PACKAGES_EOF/{f=1;next} /^BUNDLED_PACKAGES_EOF/{f=0} f && /^(brew|cask|mas)/{gsub(/ #.*/, ""); print}' /tmp/rendered.sh | sort > /tmp/brewfile-template.txt

# Rebuild installed list (with descriptions)
brew bundle dump --file=/tmp/brewfile-installed-raw.txt --force --no-vscode
grep -E '^(brew |cask |mas )' /tmp/brewfile-installed-raw.txt | sort > /tmp/brewfile-current.txt
# (run the Python annotation step if you want descriptions)

# Open diff
code --diff /tmp/brewfile-current.txt /tmp/brewfile-template.txt
```

Red line (left only) = installed but not tracked → add to template or uninstall
Green line (right only) = tracked but not installed → will be installed on next `chezmoi apply`

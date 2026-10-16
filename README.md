# dotfiles

My [dotfiles][url-dotfiles] managed with [chezmoi][url-chezmoi].

> [!IMPORTANT]
>
> - Compatible with **macOS only**.
> - Proficiency with **chezmoi** is required.

## Architecture

This repository manages **software** and **configuration files** across different **machine types**.

### Machine types

The available options are defined in [`.chezmoi.toml.tmpl`][file-chezmoi-config]. Currently:

- **`personal`**
- **`work`**

During the [initial setup](#initialization), you will be **prompted to select either one** for your machine. Your choice will be stored in your local chezmoi configuration file in `$HOME/.config/chezmoi/chezmoi.toml` to dynamically resolve which software and configuration files to apply.

For more details, see the [chezmoi machine-to-machine management guide][url-chezmoi-manage-machine].

### Software

Provisioned by [**Homebrew**][url-homebrew].

Supported package types:

- **CLI tools** (`formulae`)
- **GUI apps** and **fonts** (`casks`)

The **package list** is declared in the [package installation script][file-script-install-packages] as an embedded `Brewfile`. It's divided into groups: common packages shared across machines, and machine-specific groups.

The **script runs** `brew bundle install` to install the declared packages before configuration files are applied, both **on initial setup** and **whenever the package list changes**. Removing a package from the list does _not_ automatically uninstall it from your machine; you also need to run `brew uninstall <package>`.

### Configuration files

**Source files** are in the [`home/`][dir-home] subdirectory in this repository (as configured in [`.chezmoiroot`][file-chezmoi-root]).

**Target files** are in your `$HOME` directory.

**Ignored files** are declared in [`.chezmoiignore`][file-chezmoi-ignore].

To see the **list of all managed target files**, run `chezmoi managed` or inspect [`MANAGED.txt`][file-managed-txt].

> [!NOTE]
> **`MANAGED.txt`** is an automated, self-updating directory tree **snapshot of all managed target files**. It's a custom feature of this repository.
>
> When changes in `home/` are committed, [`.husky/pre-commit`][file-pre-commit-hook] automatically runs [`scripts/managed.js`][file-managed-js] to update `MANAGED.txt` and stages it.
>
> Manual regeneration is rarely needed, but can be triggered via `npm run managed`.

## Initial setup

To set up **a new machine with this repository** for the first time:

### Prerequisites

1. **Install Homebrew** as described at [brew.sh][url-homebrew].
2. **Install chezmoi** with Homebrew by running `brew install chezmoi`.

### Initialization

Initialize chezmoi with this repository into either:

- the default path (`~/.local/share/chezmoi`):

  ```sh
  chezmoi init germanfrelo/dotfiles
  ```

- a custom path:

  ```sh
  chezmoi --source </path/to/dotfiles> init germanfrelo/dotfiles
  ```

This will prompt you to select a machine type, clone this repository into the specified directory, and generate your local chezmoi config file. For more details, see the [`chezmoi init` reference][url-chezmoi-ref-init].

### Review and apply

1. **Check differences:** Preview what changes chezmoi will make to your machine by running `chezmoi diff`.
2. **Edit locally (optional):** Make local adjustments as described in the [chezmoi usage FAQ][url-chezmoi-edit-dotfiles] (do _not_ commit to Git yet).
3. **Apply changes:** Run `chezmoi apply --verbose`.
4. **Reboot:** Restart your machine to ensure all changes take effect.

## Post-setup

In your local dotfiles repository directory, once [Node.js][doc-node-npm] is installed, install the development dependencies to activate Git hooks (which keep [`MANAGED.txt`][file-managed-txt] synchronized) and shell linting tools:

- **Node.js** dependencies:

  ```sh
  npm install
  ```

- **Homebrew** dependencies (declared in [Brewfile][file-brewfile]):

  ```sh
  brew bundle install --file=./Brewfile
  ```

## Updating from remote

To update your machine with the **latest changes** from the remote repo:

1. **Pull** the latest changes:

   ```sh
   chezmoi git pull -- --autostash --rebase
   ```

2. **Check** the differences:

   ```sh
   chezmoi diff
   ```

3. **Apply** the changes:

   ```sh
   chezmoi apply
   ```

For more details, see the [chezmoi daily operations guide][url-chezmoi-daily-operations].

## Bootstrapping a new machine

After `chezmoi` completes the initial setup on a fresh machine, execute the following manual bootstrap actions in order.

### 1. Reload your shell session

```sh
exec zsh
```

### 2. SSH (`personal` only)

Right after all packages are installed via chezmoi and before proceeding with any Git operations:

#### 2.1. Enable managing SSH with 1Password

1. Open the 1Password desktop app and log in.
2. Navigate to `Settings` → `Developer` and verify that `Use the SSH Agent` is enabled.

This activates the 1Password agent socket referenced in `~/.ssh/config`, allowing Git to authenticate network operations via your SSH key.

#### 2.2. Switch this 'dotfiles' repository's remote from HTTPS to SSH

Since `chezmoi init` cloned this repository over HTTPS during the initial bootstrapping, switch its remote to SSH:

```sh
cd "$(chezmoi source-path)/.." && git remote set-url origin git@github.com:germanfrelo/dotfiles.git
```

### 3. Local repositories (`personal` only)

Select and **batch** clone _your_ GitHub repositories locally. Authenticate and choose one of the batch cloning methods.

Reference: [GitHub CLI manual][url-github-cli-manual].

#### 3.1. Authenticate via GitHub CLI

Run:

```sh
gh auth login
```

During the interactive prompts, select:

- **What account do you want to log into?** `GitHub.com`.
- **What is your preferred protocol for Git operations?** `SSH`.
- **Upload your SSH public key to your GitHub account?** `Skip` (your SSH key is already registered on your GitHub account).
- **How would you like to authenticate GitHub CLI?** `Login with a web browser`.

#### 3.2A. Interactive method (recommended)

> [!NOTE]
> This method requires [`fzf`][url-fzf]. If it's not installed, either [install it using Homebrew][url-fzf-installation] (recommended) or use the alternative [manual method](#32b-manual-method-fallback) below.

Review and select the repos you want to clone interactively (`Ctrl+A` to select all, `Tab` on `dotfiles` or unwanted entries to deselect, `Enter` to clone):

**Source repos:**

```sh
# Clone owned source repos into $REPOS_DIR
cd "${REPOS_DIR}"
if command -v fzf >/dev/null 2>&1; then
  gh repo list --source --no-archived --limit 1000 --json name --jq '.[].name' \
    | fzf -m --bind 'ctrl-a:select-all,ctrl-d:deselect-all' --header 'Tab: toggle | Ctrl+A: select all | Enter: clone' \
    | xargs -n 1 sh -c 'echo "----------" && gh repo clone "$1"' _
else
  echo "fzf not found. Either install it ('brew install fzf') or use the fallback method below." >&2
fi
```

**Forks:**

```sh
# Clone personal account forks into $FORKS_DIR
cd "${FORKS_DIR}"
if command -v fzf >/dev/null 2>&1; then
  gh repo list --fork --no-archived --limit 1000 --json name --jq '.[].name' \
    | fzf -m --bind 'ctrl-a:select-all,ctrl-d:deselect-all' --header 'Tab: toggle | Ctrl+A: select all | Enter: clone' \
    | xargs -n 1 sh -c 'echo "----------" && gh repo clone --no-upstream "$1"' _
else
  echo "fzf not found. Either install it ('brew install fzf') or use the fallback method below." >&2
fi
```

#### 3.2B. Manual method (fallback)

**Source repos:**

```sh
# 1. Export the repository names to a temporary file and open it in your editor:
cd "${REPOS_DIR}"
gh repo list --source --no-archived --limit 1000 --json name --jq '.[].name' > /tmp/repos.txt
code /tmp/repos.txt

# 2. Remove any unwanted repositories, save and run:
xargs -n 1 sh -c 'echo "----------" && gh repo clone "$1"' _ < /tmp/repos.txt
```

**Forks:**

```sh
# 1. Export the repository names to a temporary file and open it in your editor:
cd "${FORKS_DIR}"
gh repo list --fork --no-archived --limit 1000 --json name --jq '.[].name' > /tmp/forks.txt
code /tmp/forks.txt

# 2. Remove any unwanted repositories, save and run:
xargs -n 1 sh -c 'echo "----------" && gh repo clone --no-upstream "$1"' _ < /tmp/forks.txt
```

[dir-home]: /home/
[doc-node-npm]: /docs/set-up/how-to-node-npm.md
[file-brewfile]: /Brewfile
[file-chezmoi-config]: /home/.chezmoi.toml.tmpl
[file-chezmoi-ignore]: /home/.chezmoiignore
[file-chezmoi-root]: /.chezmoiroot
[file-managed-js]: /scripts/managed.js
[file-managed-txt]: /MANAGED.txt
[file-pre-commit-hook]: /.husky/pre-commit
[file-script-install-packages]: /home/.chezmoiscripts/darwin/run_onchange_before_install-packages-darwin.sh.tmpl
[url-chezmoi]: https://www.chezmoi.io/
[url-chezmoi-daily-operations]: https://www.chezmoi.io/user-guide/daily-operations/
[url-chezmoi-edit-dotfiles]: https://www.chezmoi.io/user-guide/frequently-asked-questions/usage/#how-do-i-edit-my-dotfiles-with-chezmoi
[url-chezmoi-manage-machine]: https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/
[url-chezmoi-ref-init]: https://www.chezmoi.io/reference/commands/init/
[url-dotfiles]: https://dotfiles.github.io/
[url-fzf]: https://github.com/junegunn/fzf
[url-fzf-installation]: https://github.com/junegunn/fzf#installation
[url-github-cli-manual]: https://cli.github.com/manual/
[url-homebrew]: https://brew.sh/

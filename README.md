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

### Development dependencies

In your local dotfiles repository directory, once [Node.js][doc-node-npm] is installed, install the development dependencies to activate Git hooks (which keep [`MANAGED.txt`][file-managed-txt] synchronized) and shell linting tools:

- **Node.js** dependencies:

  ```sh
  npm install
  ```

- **Homebrew** dependencies (declared in [Brewfile][file-brewfile]):

  ```sh
  brew bundle install --file=./Brewfile
  ```

### SSH (`personal` only)

Enable the 1Password SSH agent and switch this repository's remote from HTTPS to SSH as described in the [SSH setup guide][doc-ssh].

### Local repositories (`personal` only)

Authenticate via GitHub CLI and batch-clone your GitHub repositories locally as described in the [local repositories setup guide][doc-local-repos].

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

[dir-home]: /home/
[doc-local-repos]: /docs/set-up/how-to-local-repositories.md
[doc-node-npm]: /docs/set-up/how-to-node-npm.md
[doc-ssh]: /docs/set-up/how-to-ssh.md
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
[url-homebrew]: https://brew.sh/

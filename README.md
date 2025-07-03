# github.com/germanfrelo/dotfiles

My dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

This repository helps me manage my configuration files (dotfiles) across multiple machines, allowing me to set up and synchronize them as quickly and automatically as possible.

## Key Features & Managed Aspects

- **Cross-Platform Support:** Configurations adapted for macOS, Linux, and Windows.
- **Declarative Package Management:**
  - Homebrew formulae, casks, and Mac App Store apps (macOS).
  - TODO: System package managers (e.g., `apt`, `dnf`, `pacman` on Linux).
  - TODO: Windows package managers (e.g., Chocolatey, Winget).
- **Shell Configuration:** `zsh`, `bash`, etc.
- **Git Configuration:** Global `.gitconfig` settings.
- **Application Preferences:** Direct management of various application configuration files.
- **OS-Specific Settings:** Automated macOS `defaults` commands (TODO: and similar for Linux/Windows).

> [!WARNING]
> Before using these dotfiles, first fork this repository so that you can tweak it the way you want. After that, review the code and modify or remove anything unnecessary. Use them only if you understand their implications. **Proceed at your own risk!**

## Getting started

### 1. Before You Begin: Preparing Your Machine

There are two main scenarios before you apply these dotfiles:

- **Scenario A: It's a completely fresh OS installation.** This means the machine has just gone through its initial setup, or it's a clean slate with no personal data, apps, or configurations yet.
- **Scenario B: It's an existing machine with current data.** This machine has been in use, and it contains apps, settings, configuration files, or personal data that you **do not want replaced or lost** by applying these dotfiles.

Regardless of your scenario, it's always a good idea to perform the following:

#### 1.1. Data Backup (Crucial for Scenario B)

If you are in **Scenario B** (an existing machine), it is **crucial to back up all your existing data** before applying these dotfiles. Applying dotfiles can overwrite existing configurations and files, so a backup ensures you don't lose anything important. Go through this checklist:

- Did you **commit and push** any changes/branches to your Git **repositories**?
- Did you remember to **save** all important **documents** from **non-cloud directories**?
- Did you **save** all your **work from apps which aren't synced through cloud services**?
- Did you remember to **export important data** from your **local database**?

#### 1.2. Initial OS Setup & Updates (For Both Scenarios)

For both scenarios, complete any basic operating system setup (like the macOS Setup Assistant or initial Windows configuration) and **update your Operating System to the latest version** before proceeding. This ensures you have the latest security patches and a stable base for your new setup.

### 2. Install `chezmoi` & apply dotfiles

For more information, see [chezmoi's quick start](https://www.chezmoi.io/quick-start/).

#### 2.1. Install `chezmoi`

Use the appropriate command for your operating system:

**Using curl (Linux and macOS):**

```console
sh -c "$(curl -fsLS get.chezmoi.io)"
```

Using PowerShell (Windows):

```console
iex "&{$(irm '<https://get.chezmoi.io/ps1')}>"
```

#### 2.2. Initialize `chezmoi` with this dotfiles repo

Run:

```console
chezmoi init germanfrelo
```

This command will check out the repo and optionally create a`chezmoi` config file for you.

#### 2.3. Review and apply changes

Check what changes `chezmoi` will make to your home directory by running:

```console
chezmoi diff
```

If you are happy with the changes that ``chezmoi will make, then run:

```console
chezmoi apply -v
```

If you are *not* happy with the changes to a specific file, then either edit it with:

```console
chezmoi edit $FILE
```

Or, invoke a merge tool to merge changes between the current contents of the file, the file in your working copy, and the computed contents of the file:

```console
chezmoi merge $FILE
```

### 3. Restart your machine

It's recommended to restart your machine after previous steps.

## Important Notes

### Node.js, npm, and nvm

> [!IMPORTANT]
> Do ***NOT*** install **Node.js** or **nvm** via Homebrew or any system package manager:
>
> - For Node.js, always use a dedicated version manager (e.g., `nvm`).
> - Managing `nvm` itself via Homebrew is [unsupported and can lead to issues](https://formulae.brew.sh/formula/nvm).

1. [Install nvm](https://github.com/nvm-sh/nvm#install--update-script).

2. [Verify installation](https://github.com/nvm-sh/nvm#verify-installation):

    ```console
    # It should output `nvm` if the installation was successful
    command -v nvm
    ```

3. [Install the latest LTS version of Node + npm](https://github.com/nvm-sh/nvm#long-term-support):

    ```console
    nvm install --lts
    ```

4. (Optional) [Call `nvm use` automatically in a directory with a `.nvmrc` file](https://github.com/nvm-sh/nvm#calling-nvm-use-automatically-in-a-directory-with-a-nvmrc-file).

### Mackup (macOS Application Settings Sync)

**This repository does NOT use Mackup.**

`Mackup` doesn't work correctly in macOS Sonoma and later versions due to its reliance on symlinks for preferences, which can lead to data loss.

Instead, this dotfiles setup manages specific application preferences directly **by** `chezmoi`'s file copying mechanism.

## Managing Your Dotfiles

Once `chezmoi` is initialized, you manage your dotfiles using `chezmoi` commands:

- Add a new dotfile: `chezmoi add ~/.yourfile`
- Add a new directory: `chezmoi add ~/.yourdirectory`
- Update your dotfiles with latest changes: `chezmoi apply`
- View pending changes: `chezmoi diff`
- See current status: `chezmoi status`
- Edit a source file: `chezmoi edit $FILE`
- On any machine, you can pull and apply the latest changes from your repo with: `chezmoi update -v`

Remember to `git add`, `git commit`, and `git push` your changes to the dotfiles repository after making modifications with `chezmoi`.

## Additional information

### Open and log in each app

**Open each app** one by one to tell macOS (or other OS) that you are happy to run dangerous Internet software, and **log in** to the ones that require it.

### Browsers

- [Disable media key control in Google Chrome](https://www.omgchrome.com/chrome-google-music-media-keys/) → Enter `chrome://flags/#hardware-media-key-handling` in Chrome and change it to `Disabled`.

- Install **Safari web apps**:

  > [!NOTE]
  > Safari web apps are saved to the Applications folder of your home folder (`~/Applications/`). For more information, see "[Use Safari web apps on Mac - Apple Support](https://support.apple.com/104996)".

  - [**Gmail**](https://mail.google.com/mail)
    - [Getting an Unread Badge Count For the Docked Gmail Web App in macOS](https://blog.jim-nielsen.com/2023/unread-badge-macos-safari-web-app)
  - [**Photopea**](https://www.photopea.com)
  - [**Squoosh**](https://squoosh.app)

### How to set up an SSH key

Set up an **SSH key** by using *one* of the following methods:

- If you want to **use 1Password**:

  1. [Download 1Password](https://1password.com/downloads) and install it manually. If you want 1Password to be managed by Homebrew, see the [Homebrew documentation for appointing Homebrew Cask to manage a manually-installed app](https://docs.brew.sh/Tips-N'-Tricks#appoint-homebrew-cask-to-manage-a-manually-installed-app).
  2. Log in or create an account.
  3. [Set 1Password to manage SSH keys](https://developer.1password.com/docs/ssh). If you **already have SSH keys** stored in **1Password**, there is **no need to generate or delete** any SSH keys.

- If you **don't** want to **use 1Password**, run the following script (make sure to change \<your-email-address\> to the one you want to use):

  ```console
  curl https://raw.githubusercontent.com/germanfrelo/dotfiles/main/ssh.sh | sh -s "<your-email-address>"
  ```

  The file is `ssh.sh`.

  For more information, see "[Connecting to GitHub with SSH - GitHub Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)".

> [!TIP]
> I prefer using **separate SSH keys for GitHub authentication and signing**. Example: "GitHub SSH Auth Key" and "GitHub SSH Signing Key". See [reasons](https://stackoverflow.com/a/75795971).

---

> [!NOTE] > **TO DO: Personal and work GitHub accounts**
>
> - [Use multiple GitHub accounts | Advanced use cases | 1Password Developer](https://developer.1password.com/docs/ssh/agent/advanced/#use-multiple-github-accounts)
> - [SSH agent config file | 1Password Developer](https://developer.1password.com/docs/ssh/agent/config)

## References

- [A storm Homebrewin'](https://speakerdeck.com/anahkiasen/a-storm-homebrewin)
- [Getting Started with Dotfiles | Dries Vints](https://driesvints.com/blog/getting-started-with-dotfiles)
- [GitHub does dotfiles](https://dotfiles.github.io)
- [Josh Medeski's dotfiles](https://github.com/joshmedeski/dotfiles)
- [mackup: Keep your application settings in sync (OS X/Linux)](https://github.com/lra/mackup)
- [macOS Monterey: Setting up a Mac for Development | Tania Rascia](https://www.taniarascia.com/setting-up-a-brand-new-mac-for-development)
- [macOS Setup Guide](https://sourabhbajaj.com/mac-setup)
- [Mathias Bynens's dotfiles](https://github.com/mathiasbynens/dotfiles)
- [Set up a new Mac, Fast | Christoph Nakazawa](https://cpojer.net/posts/set-up-a-new-mac-fast)
- [Zach Holman's dotfiles](https://github.com/holman/dotfiles)

In general, I'd like to thank every single one who open-sources their dotfiles for their effort to contribute something to the open-source community.

## License

[LICENSE](./LICENSE).

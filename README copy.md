<!-- omit from toc -->
# germanfrelo's dotfiles

This repository helps _me_ set up and maintain _my_ Mac without the need for manual installation. It includes all the necessary information to install _my_ preferred setup of macOS according to _my_ preferences.

> [!WARNING]
> To use these dotfiles, first fork this repository. Review the code and modify or remove anything unnecessary. **Use my settings with caution, only if you understand their implications. Proceed at your own risk!**

<!-- omit from toc -->
## Table of Contents

- [A fresh macOS setup](#a-fresh-macos-setup)
  - [Back up your data](#back-up-your-data)
  - [Set up your new Mac](#set-up-your-new-mac)
  - [Clean your old Mac (optional)](#clean-your-old-mac-optional)
- [Your own dotfiles](#your-own-dotfiles)
- [Additional information](#additional-information)
  - [How to set up an SSH key](#how-to-set-up-an-ssh-key)
- [References](#references)

## A fresh macOS setup

These instructions are for setting up new Mac devices.

### Back up your data

If you're migrating from an existing Mac, you should first **make sure to back up all of your existing data**. Go through the following checklist to make sure you didn't forget anything before you migrate:

- Did you **commit and push** any changes/branches to your git **repositories**?
- Did you remember to **save** all important **documents** from **non-iCloud directories**?
- Did you **save** all of your **work from apps which aren't synced through iCloud**?
- Did you remember to **export important data** from your **local database**?
- Did you **update [mackup](https://github.com/lra/mackup)** to the latest version **and ran `mackup backup`**?

### Set up your new Mac

After backing up your old Mac, you may now follow these install instructions to set up a new one.

1. The **macOS setup assistant** will launch once you turn the Mac on. Enter your language, time zone, Apple ID, and so on.

2. **Update macOS** to the latest version to get the latest security updates and patches.

3. **Clone this repository** to `~/.dotfiles`:

   > [!NOTE]
   > You can use a different location than `~/.dotfiles`. If so, make sure you update the reference here, and in other files where it may be used like `.mackup.cfg`.

   - Clone using **HTTPS**:

     ```zsh
     git clone --recursive https://github.com/germanfrelo/dotfiles.git ~/.dotfiles
     ```

   - Clone using **SSH** (a password-protected SSH key is needed, see [how to set it up](#how-to-set-up-an-ssh-key)):

     ```zsh
     git clone --recursive git@github.com:germanfrelo/dotfiles.git ~/.dotfiles
     ```

   > [!NOTE]
   > For more information, see "[About remote repositories - GitHub Docs](https://docs.github.com/en/get-started/getting-started-with-git/about-remote-repositories)".

4. Change the current working directory into the folder where the repository is cloned and **run the installation script**:

    ```zsh
    cd ~/.dotfiles && ./install.sh
    ```

    > [!NOTE]
    > You may have to use `sudo ./install.sh` to install the file.

5. Install **Node.js** and **npm** using [**nvm (Node Version Manager)**](https://github.com/nvm-sh/nvm):

   > [!NOTE]
   > **TO DO:** Check out:
   > - [zsh-nvm](https://github.com/lukechilds/zsh-nvm)
   > - [nvm plugin for Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nvm)
   > - [nvm zsh completion](https://www.google.com/search?q=nvm+zsh+completion&oq=nvm+zsh+completion).

   1. [**Install** nvm](https://github.com/nvm-sh/nvm#install--update-script).

   2. [**Verify** installation](https://github.com/nvm-sh/nvm#verify-installation):

      ```zsh
      # It should output `nvm` if the installation was successful
      command -v nvm
      ```

   3. [**Install** the **latest LTS** version of **Node** + **npm**](https://github.com/nvm-sh/nvm#long-term-support):

      ```zsh
      nvm install --lts
      ```

   4. [Call `nvm use` automatically in a directory with a `.nvmrc` file](https://github.com/nvm-sh/nvm#calling-nvm-use-automatically-in-a-directory-with-a-nvmrc-file).

6. **Restart your Mac**.

7. **Open each app** one by one to tell macOS that you are happy to run dangerous Internet software, and **log in** to the ones that require it.

8. [Disable media key control in Google Chrome](https://www.omgchrome.com/chrome-google-music-media-keys/) → Enter `chrome://flags/#hardware-media-key-handling` in Chrome and change it to `Disabled`.

9. Install **Safari web apps**:

   > [!NOTE]
   > Safari web apps are saved to the Applications folder of your home folder (`~/Applications/`). For more information, see "[Use Safari web apps on Mac - Apple Support](https://support.apple.com/104996)".

   - [**Gmail**](https://mail.google.com/mail)
     - [Getting an Unread Badge Count For the Docked Gmail Web App in macOS](https://blog.jim-nielsen.com/2023/unread-badge-macos-safari-web-app)
   - [**Photopea**](https://www.photopea.com)
   - [**Squoosh**](https://squoosh.app)

Your Mac is now ready to use!

### Clean your old Mac (optional)

After you've set up your new Mac, you may want to wipe and clean install your old Mac. Follow the "[Erase and reinstall macOS](https://support.apple.com/guide/mac-help/erase-and-reinstall-macos-mh27903/mac)" official user guide to do that.

> [!IMPORTANT]
> Remember to **[back up your data](#back-up-your-data) first**!

## Your own dotfiles

> [!IMPORTANT]
> **Oh My Zsh is required.**
> Make sure to install [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) before following the instructions below.

1. **Fork this repository**. After that you can tweak it the way you want.

2. Go through the **`.macos`** file and adjust the settings to your liking. You can find much more settings at [the original script by Mathias Bynens](https://github.com/mathiasbynens/dotfiles/blob/master/.macos) and [Kevin Suttle's macOS Defaults project](https://github.com/kevinSuttle/MacOS-Defaults).

3. Check out the **`Brewfile`** file and adjust the apps you want to install for your machine. Use the [Homebrew homepage](https://brew.sh) to check if the app you want to install is available.

4. You can adjust the **`.zshrc`** file to your liking to tweak your Oh My Zsh setup. More info about how to customize Oh My Zsh can be found at the [Customization section of the Oh My Zsh Wiki page](https://github.com/ohmyzsh/ohmyzsh/wiki/Customization).

5. When creating these dotfiles for the first time, you'll need to back up all of your settings with **Mackup**. Install Mackup and back up your settings with the commands below. Your settings will be synced to Dropbox so you can use them to sync between computers and reinstall them when reinstalling your Mac. If you want to save your settings to a different directory or different storage than Dropbox, check out the [Mackup documentation](https://github.com/lra/mackup/blob/master/doc/README.md#storage).

   1. Install Mackup:

      ```zsh
      brew install mackup
      ```

   2. Use Mackup:

      ```zsh
      mackup backup
      ```

6. Go through the files in this repository and tweak everything to your liking.

## Additional information

### How to set up an SSH key

Set up an **SSH key** by using _one_ of the following methods:

- If you want to **use 1Password**:

  1. [Download 1Password](https://1password.com/downloads) and install it manually. If you want 1Password to be managed by Homebrew, see the [Homebrew documentation for appointing Homebrew Cask to manage a manually-installed app](https://docs.brew.sh/Tips-N'-Tricks#appoint-homebrew-cask-to-manage-a-manually-installed-app).
  2. Log in or create an account.
  3. [Set 1Password to manage SSH keys](https://developer.1password.com/docs/ssh). If you **already have SSH keys** stored in **1Password**, there is **no need to generate or delete** any SSH keys.

- If you **don't** want to **use 1Password**, run the following script (make sure to change \<your-email-address\> to the one you want to use):

  ```zsh
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

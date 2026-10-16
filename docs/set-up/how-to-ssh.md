# How to manage SSH keys in this dotfiles repo

Set up an **SSH key** by using _one_ of the following methods:

- If you want to **use 1Password**:

  1. [Download 1Password](https://1password.com/downloads) and install it manually. If you want 1Password to be managed by Homebrew, see the [Homebrew documentation for appointing Homebrew Cask to manage a manually-installed app](https://docs.brew.sh/Tips-N'-Tricks#appoint-homebrew-cask-to-manage-a-manually-installed-app).
  2. Log in or create an account.
  3. [Set 1Password to manage SSH keys](https://developer.1password.com/docs/ssh). If you **already have SSH keys** stored in **1Password**, there is **no need to generate or delete** any SSH keys.

- If you **don't** want to **use 1Password**, run the following script (make sure to change \<your-email-address\> to the one you want to use):

  ```sh
  curl https://raw.githubusercontent.com/germanfrelo/dotfiles/main/ssh.sh | sh -s "<your-email-address>"
  ```

  The file is `ssh.sh`.

  For more information, see "[Connecting to GitHub with SSH - GitHub Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)".

> [!TIP]
> I prefer using **separate SSH keys for GitHub authentication and signing**. Example: "GitHub SSH Auth Key" and "GitHub SSH Signing Key". See [reasons](https://stackoverflow.com/a/75795971).

---

> [!NOTE] > **TO DO: Personal and work GitHub accounts**
>
> - [Use multiple GitHub accounts | Advanced use cases | 1Password Developer](https://developer.1password.com/docs/ssh/agent/advanced/#use-multiple-github-accounts)
> - [SSH agent config file | 1Password Developer](https://developer.1password.com/docs/ssh/agent/config)

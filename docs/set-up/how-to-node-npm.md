# Node.js, npm, and nvm

> [!IMPORTANT]
> Do **_NOT_** install **Node.js** or **nvm** via Homebrew or any system package manager:
>
> - For Node.js, always use a dedicated version manager (e.g., `nvm`).
> - Managing `nvm` itself via Homebrew is [unsupported and can lead to issues](https://formulae.brew.sh/formula/nvm).

1. [Install nvm](https://github.com/nvm-sh/nvm#install--update-script).

2. [Verify installation](https://github.com/nvm-sh/nvm#verify-installation):

   ```sh
   # It should output `nvm` if the installation was successful
   command -v nvm
   ```

3. [Install the latest LTS version of Node + npm](https://github.com/nvm-sh/nvm#long-term-support):

   ```sh
   nvm install --lts
   ```

4. (Optional) [Call `nvm use` automatically in a directory with a `.nvmrc` file](https://github.com/nvm-sh/nvm#calling-nvm-use-automatically-in-a-directory-with-a-nvmrc-file).

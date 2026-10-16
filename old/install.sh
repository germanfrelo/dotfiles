#!/bin/sh

# IMPORTANT! The order of the followings actions is critical.

echo "Setting up your Mac…"

# --------------------------------------------------

# Zsh for Humans
# https://github.com/romkatv/zsh4humans

echo "Installing "Zsh for Humans" (zsh4humans)…"
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
fi

# --------------------------------------------------

# Homebrew
# https://brew.sh

# Install Homebrew (if it's not installed).
if test ! $(which brew); then
  echo "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --------------------------------------------------

# Applications via Brewfile (Homebrew)

# Install all CLI and GUI applications (including fonts) from the Brewfile.

echo "Installing all CLI and GUI applications (including fonts) from the Brewfile…"
brew bundle --global --no-lock

echo "Checking if all dependencies present in the Brewfile are installed…"
brew bundle check

# --------------------------------------------------

# Clone repositories

# Create a projects directories and clone GitHub.
# TODO
# mkdir $HOME/___
# ./clone.sh

# --------------------------------------------------

# Mackup (applications settings and config files)

# Symlink the Mackup config file from this repo to your home directory.
# IMPORTANT! It _must_ be in your home directory. See https://github.com/lra/mackup/blob/master/doc/README.md#configuration.
ln -s ./.mackup.cfg $HOME/.mackup.cfg

# TODO
mackup --version
# Restore (symlink) the config files already from this repo to their corresponding directories.
mackup restore --dry-run --verbose
# mackup restore --verbose

# --------------------------------------------------

# macOS settings

# Set macOS settings.
# IMPORTANT! This must be run last because this will reload the shell.
# TODO
# source ./.macos

# --------------------------------------------------

# Restart your computer

echo "Restart your computer to finalize the process."

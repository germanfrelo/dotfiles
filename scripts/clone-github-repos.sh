#!/usr/bin/env bash

# ========================================
# Clone Personal GitHub Repositories
#
# Clones non-archived personal GitHub repos and forks to their designated local directories.
#
# Dependencies:
# - git (macOS natively provides this via Xcode Command Line Tools).
# - gh (GitHub CLI) - Must be installed and authenticated (`gh auth login`).
# - Environment variables: $REPOS_DIR and $FORKS_DIR must be sourced from your .zshrc.
# ========================================

# Exit immediately if a command exits with a non-zero status or an undefined variable is referenced.
set -euo pipefail

# ----- CONFIGURATION -----

# ❗️ IMPORTANT: The local destination paths for '$REPOS_DIR' and '$FORKS_DIR' are defined in '$ZDOTDIR/.zshrc' because they are used by other scripts or projects, ensuring a single source of truth.
# To change them, do it only there and run `exec zsh` to take effect.

# The GitHub username to fetch repositories from.
GITHUB_USER="germanfrelo"

# An array of exact repository names to skip cloning.
REPOS_TO_SKIP=("dotfiles")

# ----- PRE-FLIGHT CHECKS -----

# Fail immediately if crucial environment variables are not set.
: "${REPOS_DIR:?Error: REPOS_DIR environment variable is not set. Ensure it is defined in '$ZDOTDIR/.zshrc' and run 'exec zsh' to load it.}"
: "${FORKS_DIR:?Error: FORKS_DIR environment variable is not set. Ensure it is defined in '$ZDOTDIR/.zshrc' and run 'exec zsh' to load it.}"

# Verify the GitHub CLI is installed.
if ! command -v gh &>/dev/null; then
	echo "  ⚠ gh CLI not found. Please install gh and authenticate before running this script."
	exit 1
fi

# Ensure the destination directories exist.
echo "  ↓ Cloning personal repositories..."
mkdir -p "${REPOS_DIR}" "${FORKS_DIR}"

# ----- HELPERS -----

# Dynamically construct a regex string from the skip array (e.g. "^(dotfiles)$").
SKIP_REGEX="^($(
	IFS="|"
	echo "${REPOS_TO_SKIP[*]}"
))$"

# DRY helper function to handle the GitHub CLI pipeline.
clone_repos() {
	local type_flag="$1"
	local target_dir="$2"

	# Fetches a JSON list of repos, filters them using grep, and passes them to git clone via xargs.
	# ❗️ IMPORTANT: If a folder already exists, xargs safely continues and git natively prints a standard fatal error.
	gh repo list "${GITHUB_USER}" "${type_flag}" --no-archived --limit 200 --json name --jq '.[].name' |
		grep -vE "${SKIP_REGEX}" |
		xargs -I {} gh repo clone "${GITHUB_USER}/{}" "${target_dir}/{}" -- -q || true
}

# ----- EXECUTION -----

# Clone non-fork repositories
clone_repos "--source" "${REPOS_DIR}"

# Clone forks
clone_repos "--fork" "${FORKS_DIR}"

echo "  ✓ Repositories cloned."

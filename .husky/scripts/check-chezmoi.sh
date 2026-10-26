#!/usr/bin/env bash

# Checks for source state changes, and if found, prompts to sync.

# Check if inside a git repository.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	exit 0 # Skip silently
fi

# Check if there are any commits yet.
if ! git rev-parse --quiet HEAD >/dev/null 2>&1; then
	exit 0 # Skip silently
fi

# Resolve the root of the source state dynamically from .chezmoiroot (defaults to the repository root).
source_root="$(head -n 1 .chezmoiroot 2>/dev/null | tr -d '[:space:]')"
source_root="${source_root:-.}"

# Check if chezmoi source root exists.
if [[ ! -d "${source_root}" ]]; then
	exit 0 # Skip silently
fi

# Check if the source state changed between the previous and current commits.
if ! git diff --quiet 'HEAD@{1}' HEAD -- "${source_root}/" >/dev/null 2>&1; then
	# Differentiate initial clone checkout from subsequent branch switches or merges.
	if ! git rev-parse --verify 'HEAD@{1}' >/dev/null 2>&1; then
		echo "🏠ℹ️ Initial clone checkout. Run 'chezmoi diff' and 'chezmoi apply -v' to sync dotfiles."
	else
		echo "🏠❗ Dotfiles under '${source_root}/' have changed. Run 'chezmoi diff' and 'chezmoi apply -v' to sync."
	fi
fi

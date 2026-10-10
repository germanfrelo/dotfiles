#!/usr/bin/env bash

# Checks if any Brewfile changed during the git pull/merge.
# If so, reminds the user to reconcile common packages across machines.

# Check if inside a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	exit 0 # Skip silently
fi

# Check if there are any commits yet
if ! git rev-parse --quiet HEAD >/dev/null 2>&1; then
	exit 0 # Skip silently
fi

# Check for changes in the homebrew directory between the previous HEAD and current HEAD
if ! git diff --quiet HEAD@{1} HEAD -- home/private_dot_config/homebrew/ >/dev/null 2>&1; then
	echo "💡 Reminder: A source Brewfile was updated in this pull."
	echo "If a package belongs on both machines, consider syncing them:"
	echo "   code --diff home/private_dot_config/homebrew/personal/Brewfile home/private_dot_config/homebrew/work/Brewfile"
fi

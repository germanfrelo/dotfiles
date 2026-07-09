---
status: accepted
date: 2026-06-02
---

# VS Code Settings Sync is primary; chezmoi is a secondary git-tracked backup

## Context and Problem Statement

`settings.json`, `prompts/*.instructions.md`, and `snippets/*.json` are managed by chezmoi and therefore tracked in git. VS Code Settings Sync also manages these same files, syncing them across machines via a GitHub account. Both systems write to the same live files, creating a conflict: if Settings Sync pulls a newer version from the cloud, chezmoi's source becomes stale; if `chezmoi apply` runs afterwards, it silently overwrites Settings Sync's version with the stale backup.

## Considered Options

- chezmoi primary, Settings Sync disabled for overlapping categories
- Settings Sync primary, chezmoi secondary (backup direction only)
- Disable chezmoi tracking for VS Code files entirely

## Decision Outcome

Chosen option: **Settings Sync primary, chezmoi secondary**, because Settings Sync provides automatic, zero-maintenance sync across machines (including extensions and other categories not in chezmoi) and is backed by a GitHub account, making it the most reliable real-time source. chezmoi provides git history and offline recoverability — benefits that require no additional tooling given the files are already in the repo.

All Settings Sync categories remain enabled. chezmoi is never used to push VS Code files to the live directory in normal use — only to capture snapshots from it via `re-add`.

## Consequences

### Normal workflow

When `chezmoi status` shows a VS Code file as `MM` (changed since chezmoi last wrote it), the correct action is always `chezmoi re-add` to update the backup, not `chezmoi apply` to overwrite the live file.

### `chezmoi apply` conflict rule

If `chezmoi apply` prompts about a VS Code file, always choose **keep destination** (Settings Sync's version wins). Immediately follow with `chezmoi re-add` and a commit to bring the source back in sync.

### New machine procedure

`chezmoi apply` runs first to write the backup as a baseline, then VS Code signs in and Settings Sync runs. If Settings Sync shows a "Local vs Cloud" conflict, choose **Accept Cloud**. See [chezmoi.md — VS Code managed files](/docs/chezmoi.md#vs-code-managed-files) for the full step-by-step.

### What is not tracked in chezmoi

Extensions, keyboard shortcuts, tasks, MCP servers, UI state, and profiles are managed by Settings Sync only and are not tracked in chezmoi.

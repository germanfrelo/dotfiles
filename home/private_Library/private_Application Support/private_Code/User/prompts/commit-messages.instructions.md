---
name: Commit messages
description: "Git commit message conventions — Conventional Commits spec, atomic commits, commit message format and workflow"
applyTo: "**"
---

## Text formatting

- Never hard-wrap text or enforce any maximum line length. Whether generating new content or modifying existing files (including chat responses, code comments, markdown, and commit messages), write each logical sentence or paragraph as a single unbroken line and let the editor soft-wrap it.

## Pre-commit workflow

- Before suggesting any commits, always run `git status` and `git log --oneline -5` to verify the actual working tree state. Never suggest commit contents or file lists based on assumptions about what has or hasn't been committed.
- If `git status` shows a clean working tree, respond that there is nothing to commit and do not fabricate a commit message.
- Before writing a commit message, run `git diff --staged` to identify all logical changes present in the staged diff and confirm whether they belong to one commit.
- If `git diff --staged` is empty, do not propose a commit. Instead, list unstaged/untracked changes from `git status` and ask the user which to stage.

## Format

- Follow the Conventional Commits specification. Use the form `type: Message title` without a scope. Do not include a scope unless the repository convention requires it.
- Allowed types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`. Use `feat` for new user-facing features, `fix` for user-facing bug fixes, `style` for formatting-only changes with no semantic impact (whitespace, punctuation, Markdown rendering), `chore` for maintenance tasks. TODO: Finish defining types and their usage guidelines.
- Subject line must be written in the imperative mood ("Add feature", not "Added" or "Adds").
- Commit message subject format: `type: Message title`
  - Type in lowercase: `type:`
  - First letter after the colon and space must be uppercase. Correct: `chore: Add cache options`. Incorrect: `chore: add cache options`.
- If you notice the user using lazy, generic, or non-conventional commit messages (e.g., `WIP`, `update`, `fix` as a standalone message), aggressively push back and ask the user to reword the commit following the Conventional Commits spec.
- The subject line should describe the outcome or intent (the what), while the body explains the implementation details (the how and why).
- If the user explicitly requests a format that conflicts with these rules, point out the conflict and follow these rules unless the user confirms an override.

## Body

- Always include a body.
- The commit body must explain _why_ the change was made, not restate what changed. The diff shows the what. Keep it high-level and outcome-focused.
- The commit body may use bullet points (`-`) to list multiple reasons or sub-points.
- For breaking changes, append a `BREAKING CHANGE: <description>` footer explaining the migration path. Do not use the `!` shorthand.
- For reverts, use `revert: <original subject>` and include `This reverts commit <hash>.` in the body.
- Use footers for issue references (`Closes #123`, `Refs #456`) and co-authors (`Co-authored-by: Name <email>`). Place footers after a blank line at the end of the body.

## Splitting commits

- When suggesting a commit or set of commits, always list the exact files to include in each commit (e.g. `git add path/to/file1 path/to/file2`). Never assume the user knows which files belong to which commit.
- **Non-negotiable top priority: atomic commits.** Never allow multiple unrelated logical changes to be mixed in a single commit, regardless of whether you or the user are creating it.
- If you detect the user attempting to commit tangled changes, you must immediately push back, stop the process, and demand that the changes be split. If you notice the user has already made a tangled commit in the recent history, explicitly point it out and suggest an interactive rebase or reset to fix it.
- Each commit must represent one logically distinct change with a single clear purpose.
- If `git diff --staged` already contains multiple unrelated logical changes, recommend unstaging with `git restore --staged .` and restaging in groups via `git add -p` before proceeding.
- Use `git add -p` for partial staging when changes to the same file belong to different commits.
- Never execute a `git commit` command yourself without first presenting a staging plan to the user (listing the exact files per commit) and receiving explicit approval to proceed.

## Publishing commits

- Never combine `git commit` and `git push` in a single compound command (e.g., `git commit ... && git push`). Always run them as separate steps — commit first, verify with `git log --oneline`, then push.

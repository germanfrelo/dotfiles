---
name: Commit messages
description: "Git commit message conventions — Conventional Commits spec, atomic commits, commit message format and workflow"
applyTo: "**"
---

## Pre-commit workflow

- Before suggesting any commits, always run `git status` and `git log --oneline -5` to verify the actual working tree state. Never suggest commit contents or file lists based on assumptions about what has or hasn't been committed.
- If `git status` shows a clean working tree, respond that there is nothing to commit and do not fabricate a commit message.
- Before writing a commit message, run `git diff --staged` to identify all logical changes present in the staged diff and confirm whether they belong to one commit.
- If `git diff --staged` is empty, do not propose a commit. Instead, list unstaged/untracked changes from `git status` and ask the user which to stage.

## Format

- Follow the Conventional Commits specification. Use the form `type: Message title` without a scope.
- Do not include a scope unless the repository convention requires it. If used, format as `type(scope): Message title`.
- Allowed types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`. Use `feat` for new user-facing features, `fix` for bug fixes, `chore` for maintenance tasks.
- Subject line must be written in the imperative mood ("Add feature", not "Added" or "Adds").
- The commit subject must be 50 characters or fewer.
- Commit message subject format: `type: Message title`
  - Type in lowercase: `type:`
  - First letter after the colon and space must be uppercase. Correct: `chore: Add cache options`. Incorrect: `chore: add cache options`.
- Avoid subjective words like "improve", "enhance", "better", or "optimise" in subjects; describe what actually changed instead (e.g. `chore: Add schedule and label options`).
- When constraints conflict, prioritise in this order: (1) imperative mood, (2) factual description, (3) avoidance of subjective words, (4) 50-character subject limit.
- If the user explicitly requests a format that conflicts with these rules, point out the conflict and follow these rules unless the user confirms an override.

## Body content and formatting

- Commit messages must be factual, not persuasive.
- The commit body must explain _why_ the change was made, not restate what changed. The diff shows the what.
- The commit body may use bullet points (`- `) to list multiple reasons or sub-points. Do not add a trailing summary sentence.
- For breaking changes, append a `BREAKING CHANGE: <description>` footer explaining the migration path. Do not use the `!` shorthand.
- For reverts, use `revert: <original subject>` and include `This reverts commit <hash>.` in the body.
- Use footers for issue references (`Closes #123`, `Refs #456`) and co-authors (`Co-authored-by: Name <email>`). Place footers after a blank line at the end of the body.
- Do not hard-wrap the commit body. Rely on soft wrapping. If a line break is needed for readability, use a blank line to separate paragraphs instead of inserting manual line breaks.

## Splitting commits

- When suggesting a commit or set of commits, always list the exact files to include in each commit (e.g. `git add path/to/file1 path/to/file2`). Never assume the user knows which files belong to which commit.
- Each commit must represent one logically distinct change with a single clear purpose.
- Before staging, identify all logical changes in the diff and group them into individual commits.
- If `git diff --staged` already contains multiple unrelated logical changes, recommend unstaging with `git reset HEAD` and restaging in groups via `git add -p` before proceeding.
- Use `git add -p` for partial staging when changes to the same file belong to different commits.
- If hunks cannot be cleanly split with `git add -p`, prefer making the commit anyway with both logical changes documented as separate bullet points in the body, and note in the body why they could not be separated.

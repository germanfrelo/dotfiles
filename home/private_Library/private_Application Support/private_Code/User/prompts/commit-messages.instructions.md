---
name: Commit messages
description: "Git commit message conventions — Conventional Commits spec, atomic commits, commit message format and workflow"
applyTo: "**"
---

## Pre-commit workflow

- Always run `git status` and `git log --oneline -5` before suggesting commits. Never assume working tree state.
- If clean, do not fabricate a commit message.
- Run `git diff --staged` before writing a message to verify logical changes belong in one commit.
- If staged diff is empty, list unstaged changes and ask what to stage instead of proposing a commit.

## Format

- Follow Conventional Commits (relying on your built-in knowledge for allowed types). Use the form `type: Message title` without a scope unless the repository convention requires it.
- Subject line: imperative mood ("Add", not "Added"), first letter uppercase after colon.
- Subject describes intent/outcome (the what); body explains implementation (the how and why).
- Aggressively push back on lazy messages (`WIP`, `update`) and demand Conventional Commits unless an explicit override is given.

## Body

- Include a body by default, especially for multiple or complex changes. Omit the body only for simple, self-explanatory changes (e.g., file renames, formatting, fixing typos) where the subject line sufficiently explains the "what" and the "why". If omitted for a simple change, do not push back.
- When included, the body must explain _why_ the change was made, not restate what changed. Keep it high-level and outcome-focused.
- May use bullet points (`-`). Do not hard-wrap lines.
- Breaking changes: append a `BREAKING CHANGE: <description>` footer. Do not use the `!` shorthand.
- Reverts: use `revert: <original subject>` and include `This reverts commit <hash>.` in the body.
- Footers (issues, co-authors): place after a blank line at the end of the body.

## Splitting commits

- **Non-negotiable: atomic commits.** Never allow multiple unrelated logical changes in a single commit. Demand tangled changes be split. Suggest rebase/reset for recent tangled history.
- Always list exact files per commit (e.g., `git add <files>`) when suggesting a plan. Never assume the user knows.
- If staged changes are tangled, explicitly state they are tangled and propose how to split them into atomic commits. Wait for approval before proceeding.
- Use `git add -p` for partial staging when changes to the same file belong to different commits.
- Never execute `git commit` without presenting a staging plan (listing exact files per commit) and receiving explicit approval.

## Publishing commits

- Never run compound `git commit ... && git push`. Always commit first, verify with `git log --oneline`, then push.

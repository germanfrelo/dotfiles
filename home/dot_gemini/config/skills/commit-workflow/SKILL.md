---
name: commit-workflow
description: Reviews changes, proposes atomic commits, and writes commit messages following the Conventional Commits specification. Use this when you need to commit changes to a Git repository.
---

# Commit Workflow

This skill helps you create well-structured, atomic commits using the Conventional Commits specification.

## When to use this skill

Use this skill whenever you need to stage changes, write commit messages, or manage the git pre-commit workflow.

## How to use it

1. **Follow the pre-commit workflow**: Always run `git status` and `git log --oneline -5` before suggesting commits. If clean, do not fabricate a commit message. Run `git diff --staged` before writing a message to verify logical changes belong in one commit. If staged diff is empty, list unstaged changes and ask what to stage instead of proposing a commit.
2. **Split commits atomically**: Never allow multiple unrelated logical changes in a single commit. Demand tangled changes be split. Always verify the semantic meaning of each change line-by-line. Always list exact files per commit when suggesting a plan. If `git diff --staged` contains multiple unrelated logical changes, propose how to split them. Never execute `git commit` without presenting a staging plan and receiving explicit approval.
3. **Format the commit message**: Follow the Conventional Commits specification. Use the form `type: Message title` without a scope unless required. The subject line must be in imperative mood with the first letter uppercase after the colon. Push back on lazy messages.
4. **Write the body**: Include a body by default explaining why the change was made. May use bullet points. Append a `BREAKING CHANGE: <description>` footer for breaking changes. Place footers (issues, co-authors) after a blank line at the very end.
5. **Publish commits**: Never run compound `git commit ... && git push`. Always commit first, verify with `git log --oneline`, then push.

---
trigger: always_on
description: "Global conventions for text formatting, communication, code style, and Git."
---

# General Conventions

When a workspace-specific instruction conflicts with this file, the workspace-specific rule takes precedence; flag the conflict on first encounter.

## Text formatting

- Never hard-wrap text at an arbitrary character limit (e.g., 80 columns). Apply these rules to chat responses, code comments, and markdown files:
  - **Prose**: Use semantic line breaks (write each logical sentence as a single unbroken line).
  - **Paragraphs**: Use blank lines to separate them.
  - **List items**: Write the entire item as a single unbroken line.

## Communication

- Act as a rigorous analyst: do not accept the user's ideas at face value or seek to validate them; spot errors, biases, and unfounded assumptions, state clearly when a decision is wrong, and challenge the user's analysis with difficult questions.
- When multiple valid options exist, recommend the single best one with a brief rationale, and list alternatives when they differ on a dimension the user must decide.
- End each response with a "Pending actions" section listing follow-up steps (or the most relevant next step for substantive replies); carry unresolved actions forward across intermediate questions, and omit only for pure acknowledgements with no open tasks.

## Chat response formatting

@[Shared Markdown Rules](_markdown-rules-shared.md)
<!-- prettier-ignore -->
- Always use 4 tilde characters (`~~~~`) for the **outer** fence of all code blocks because tilde fences cannot be closed by inner backtick fences of any length.
- Never insert a horizontal rule (`---`) before a heading.

## Writing

- Use clear, direct, and concise language. Avoid filler words, corporate jargon, and typical AI fluff.
- End list items with a full stop. Items consisting of a single word or a bare code span are exempt.
- Never duplicate data from a canonical source (configs, `package.json`, code, generated files) in secondary documents (READMEs, docs, instructions); reference the canonical source instead, or flag the duplication risk and cite the source if inlining is unavoidable.

## Code

- Code identifiers, comments, and commit messages: always English, regardless of response language.
- In comments, explain the causal rationale, intent, or failure mode prevented ("why") rather than restating identifiers, literals, or mechanical syntax replacements ("what") that go stale; point to the canonical source when needed, and keep comments agnostic of external callers unless intrinsically coupled.

## Version control

- Never open a pull request unless explicitly asked.
- Always use the tilde syntax (e.g. `HEAD~1`, `commit~1`) instead of the caret syntax (`^`) for Git parent references because the caret triggers Zsh history expansion errors.
- Prioritize modern, specialized Git commands over older, overloaded equivalents:
  - Use `git switch` instead of `git checkout` for branching.
  - Use `git restore` instead of `git checkout` or `git reset` for unstaging/discarding file changes.
  - Use `git push --force-with-lease` instead of `git push -f` for safer force pushing.
  - Use `git rebase --update-refs` to automatically keep stacked branches in sync.

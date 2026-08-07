---
name: Markdown
description: "Markdown writing conventions"
applyTo: "**/*.md"
---

## Text formatting

- Never hard-wrap text or enforce any maximum line length. Whether generating new content or modifying existing files (including chat responses, code comments, markdown, and commit messages), write each logical sentence or paragraph as a single unbroken line and let the editor soft-wrap it.

## Rules

- Use headings (`##` or deeper) for named sections. Do not use bold text (`**title**`) as a substitute for a section heading.
- Use absolute paths starting with `/` for workspace internal links (e.g., `[file](/docs/file.md)`) instead of relative paths (`./` or `../`).

## Commands

Always run after creating or modifying an `.md` file:

```sh
npx prettier --write "<file>"
npx markdownlint-cli2 --fix "<file>"
```

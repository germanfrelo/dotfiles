---
name: Markdown
description: "Markdown writing conventions"
applyTo: "**/*.md"
---

## Rules

- Use headings (`##` or deeper) for named sections. Do not use bold text (`**title**`) as a substitute for a section heading.
- Use absolute paths starting with `/` for workspace internal links (e.g., `[file](/docs/file.md)`) instead of relative paths (`./` or `../`).

## Commands

After creating or modifying an `.md` file, check `package.json` scripts or local configurations, and run any configured Markdown formatters and linters.

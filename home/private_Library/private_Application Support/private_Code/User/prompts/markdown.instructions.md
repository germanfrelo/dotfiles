---
name: Markdown
description: "Markdown writing conventions"
applyTo: "**/*.md"
---

## Rules

- Ignore line-length limits for prose. Never hard-wrap paragraphs or list items; write each as a single unbroken line.
- Use headings (`##` or deeper) for named sections. Do not use bold text (`**title**`) as a substitute for a section heading.
- Use absolute paths starting with `/` for workspace internal links (e.g., `[file](/docs/file.md)`) instead of relative paths (`./` or `../`).

## Commands

Always run any configured formatters or Markdown linters after creating or modifying an `.md` file.

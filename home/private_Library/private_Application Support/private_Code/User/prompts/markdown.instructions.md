---
name: Markdown Lint & Enforcement
description: Apply when creating or editing any Markdown file or standalone Markdown content
applyTo: "**/*.md"
---

These rules apply to `.md` files and standalone Markdown documents, not to chat response formatting.

## Non-auto-fixable Rules

Follow these while writing — the linter handles everything else automatically.

- Do not hard-wrap prose paragraphs or list items. Write each as a single unbroken line and let the editor soft-wrap it.
- Do not end headings with `,` `.` `;` or `:` — trailing `!` is allowed.
- Do not repeat a heading title among sibling headings (same level, same parent section); identical titles at different nesting depths are allowed.
- Prefix all relative links with `./` (e.g. `[file](./file.md)`) because editors use `./` to trigger file-path autocomplete.

## Automated Verification

Whenever you finish modifying or creating a `.md` file, run:

```sh
npx markdownlint-cli2 --fix "<path_to_modified_file>"
```

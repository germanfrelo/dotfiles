---
name: Instruction writing standards
description: "Apply when creating, editing, or reviewing any .instructions.md, .prompt.md, .agent.md, AGENTS.md, or copilot-instructions.md file"
applyTo: "**/*.instructions.md,**/*.prompt.md,**/*.agent.md,**/AGENTS.md,**/copilot-instructions.md"
---

When creating or editing an instruction file, follow this workflow in order:

1. Proactively identify all gaps, contradictions, and improvement opportunities in the file — list every finding, not just the most prominent one.
2. If the request would violate these standards, point out the conflict and propose a compliant alternative before proceeding.
3. Show the complete proposed file contents in a code block (all bullets, including unchanged ones) and wait for explicit approval (e.g. "yes", "go ahead") before writing the file.
4. If the user requests changes instead of approving, revise the proposal and show the complete file again. Do not write until you receive explicit approval.
5. Apply the edit — changing only bullets the user explicitly referenced or that must change for the requested behaviour to be correct. Do not reorder, reword, or restructure unreferenced bullets.

## Rule content

- Keep each instruction short and self-contained. Each bullet must express exactly one rule. A rationale attached to a rule (introduced by "because" or in parentheses) does not count as a second rule.
- Include a brief because-clause when a rule chooses between plausible alternatives (e.g. "Use `date-fns` instead of `moment.js` because `moment.js` is deprecated and increases bundle size") or would otherwise look arbitrary. Omit reasoning for self-evident rules.
- Include code examples when the rule concerns syntax, API usage, or naming patterns. Omit examples for purely procedural rules.
- When adding a new bullet, insert it adjacent to topically related bullets within the same section. Inserting between existing bullets is not reordering; reordering means changing the position of an already-existing bullet, which is not allowed.
- Only document rules that a model must decide at generation time. Skip conventions already enforced automatically by tools — for example: indentation, quote style, trailing commas (formatters), unused variables, import order (linters).
- When writing a rule that would inline a hardcoded value (file path, setting name, command output) that already appears in a canonical or auto-generated source in the workspace, reference that source by name instead of duplicating the value, because the value will drift when the source changes.

## File structure

- When a rule only applies to one repository, keep it in that repo's instructions rather than in this global file.
- For task- or language-specific instructions, use multiple `*.instructions.md` files with targeted `applyTo` patterns instead of one large file.
- When a new instruction-file format emerges, add its glob to this file's `applyTo` only if these rules apply to it unchanged; otherwise create a separate file.

## YAML frontmatter (VS Code)

- `AGENTS.md` and `copilot-instructions.md` do not use YAML frontmatter; write rules as plain Markdown bullets only.
- Use YAML frontmatter with `name`, `description`, and `applyTo` fields. Quote `description` values that contain colons to prevent YAML parse failures.
- The `description` field serves two purposes: shown on hover in the Chat view AND used for semantic matching — when the description matches the current task, the file is applied even without a matching `applyTo`. Write descriptions that clearly reflect when the file should trigger.
- Use `applyTo: "**"` only when the rule must be evaluated for every file edit regardless of file type or path. For rules tied to specific tasks (commits, PRs, reviews), use a `description` field for semantic matching instead. For rules that apply to many but not all file types, use a comma-separated glob list (e.g. `"**/*.ts,**/*.tsx"`).

## YAML frontmatter (Claude `.claude/rules`)

- Use a `paths` array instead of `applyTo` for glob patterns. `paths` defaults to `**` when omitted.

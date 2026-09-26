---
name: evaluate-antigravity-rules
description: Evaluates and modifies Antigravity rule files for correctness, structure, and token efficiency. Use when auditing or editing rules in .gemini/config/rules/.
---

# Evaluate Antigravity Rules

This skill provides the standard workflow for evaluating, creating, and modifying Antigravity rule files (`.md` files).

## When to use this skill

Use this skill when you are asked to review, edit, or create Antigravity rules, ensuring they comply with YAML frontmatter standards and structural conventions.

## How to use it

When creating or editing a rule file, follow this workflow in order:

1. **Evaluate content**: Proactively identify all gaps, contradictions, and improvement opportunities in the file. Keep each instruction short and self-contained. Include a brief because-clause when a rule chooses between alternatives. Include code examples when the rule concerns syntax or API usage. Skip conventions already enforced automatically by tools.
2. **Ensure proper structure**: When adding a new bullet, insert it adjacent to topically related bullets within the same section. Do not reorder adjacent unreferenced bullets. Reference canonical sources instead of duplicating hardcoded values.
3. **Format YAML frontmatter**: Every `.md` file inside `rules/` must start with YAML frontmatter declaring a valid `trigger` (`always_on`, `model_decision`, `glob`, or `manual`). Include a `description` field for `model_decision` rules. For a `glob` trigger, you MUST include a `globs` field with a comma-separated list of file glob patterns. `AGENTS.md` and `GEMINI.md` do not use YAML frontmatter.
4. **Propose changes**: If the request would violate these standards, point out the conflict and propose a compliant alternative. Propose your changes clearly to the user and ask for approval.
5. **Apply edits**: Once approved, use your file editing tools to apply the changes directly. Only modify the specific rules or bullets that require changes.

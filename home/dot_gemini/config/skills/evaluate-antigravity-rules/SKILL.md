---
name: evaluate-antigravity-rules
description: "Evaluates and optimizes Antigravity rule files. Use when reviewing or editing AGENTS.md, GEMINI.md, **/.agents/rules/*.md, or ~/.gemini/config/rules/*.md."
---

# Evaluate Antigravity Rules

## 1. Audit rule file

- **Specification compliance**: Fetch the official [Antigravity rules documentation](https://antigravity.google/docs/rules.md) (via `read_url_content` or `curl -fsSL`). Audit every section and line of the target file painstakingly against the fetched specification, treating each element as non-compliant until verified against the official documentation.
- **Quality and consistency**: Check for logical contradictions, semantic ambiguity without clear operational criteria, deeply nested conditional branching, and composition conflicts with ancestor rules or included files.
- **Token efficiency**: Ensure instructions are concise, self-contained, and free of conventions already enforced automatically by linters, formatters, or Git hooks.

## 2. Report findings and apply changes

- Report findings organized by category (frontmatter, structure, contradictions, ambiguity, cognitive load, composition, token budget) with line numbers and rationale.
- Wait for explicit user confirmation before editing the file.
- Upon confirmation, modify only what is necessary to resolve the audit findings, without adding unrelated rules.

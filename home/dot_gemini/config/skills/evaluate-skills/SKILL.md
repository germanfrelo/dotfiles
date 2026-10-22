---
name: evaluate-skills
description: "Evaluates and optimizes skill folders and SKILL.md files. Use when reviewing or editing SKILL.md files in .agents/skills/ or ~/.gemini/config/skills/."
---

# Evaluate Skills

## 1. Audit skill file

- **Specification compliance**: Fetch the official [Agent Skills specification](https://agentskills.io/specification.md) and [Antigravity skills documentation](https://antigravity.google/docs/skills.md) (via `read_url_content` or `curl -fsSL`). Audit every section and line of the target file and folder structure painstakingly against both specifications, treating each element as non-compliant until verified against the official documentation.
- **Quality and consistency**: Check for logical contradictions, semantic ambiguity without clear operational criteria, deeply nested conditional branching, and unnecessary duplication of instructions already present in the prompt or global rules.
- **Progressive disclosure & budget**: Verify the three-tier progressive disclosure model (metadata in frontmatter, instructions under 500 lines in `SKILL.md`, and specialized scripts/references/assets moved to subdirectories when complex); ensure instructions are concise and self-contained.

## 2. Report findings and apply changes

- Report findings organized by category (frontmatter, naming, structure, contradictions, ambiguity, progressive disclosure, token budget) with line numbers and rationale.
- Wait for explicit user confirmation before editing the file.
- Upon confirmation, modify only what is necessary to resolve the audit findings, without adding unrelated steps.

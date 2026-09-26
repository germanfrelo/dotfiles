---
name: evaluate-skills
description: Evaluates and modifies portable open-standard skill folders and their SKILL.md files. Use when creating, auditing, or editing skills to ensure compliance with the agentskills.io standard.
---

# Evaluate Skills

This skill provides the standard workflow for evaluating, creating, and modifying portable open-standard skill instructions (`SKILL.md` files). Skills are an [open standard](https://agentskills.io/home) for extending agent capabilities. A skill is a folder containing a `SKILL.md` file with instructions that the agent can follow when working on specific tasks. Skills are reusable packages of knowledge that extend what the agent can do.

## When to use this skill

Use this skill when you are asked to review, edit, or create skills, ensuring they comply with the open skill architecture and formatting standards.

## How to use it

When creating or editing a `SKILL.md` file, follow this workflow in order:

1. **Verify skill formatting**: Ensure every skill is located in its own folder and the manifest file is strictly named `SKILL.md`. Check that skills begin with YAML frontmatter containing `name` and `description` only. The `description` field must be written in third person and include keywords.
2. **Ensure proper structure**: Ensure there are no arbitrary blockquotes like `> NOTE:`. Ensure the file has a single `# H1 Title` after the frontmatter, followed by a brief summary. Include a `## When to use this skill` section and a `## How to use it` section containing the step-by-step workflow as a numbered list.
3. **Evaluate and propose**: Proactively identify all gaps, contradictions, and improvement opportunities in the file. List every finding. Propose your changes clearly to the user and ask for approval.
4. **Apply edits**: Once approved, apply the changes directly. Only modify the specific rules or bullets that require changes. Do not reorder or restructure adjacent unreferenced bullets.

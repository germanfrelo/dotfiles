# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records (ADRs). These files capture the _why_ behind low-frequency, non-obvious, easily forgotten architectural and configuration decisions in my dotfiles repository.

## Format: MADR (Markdown Any Decision Records)

I follow the [MADR specification](https://adr.github.io/madr) (a structured extension of Michael Nygard's original 2011 format).

MADR's crucial addition is the **"Considered Options"** section. Documenting the alternatives I rejected (and why) is just as important as documenting the path I chose.

### Writing an ADR

1. **Naming:** Use the format `NNNN-short-title.md` (e.g., `0001-remove-zprofile.md`). The title should describe the decision made, not just the topic.
2. **Template:** Use the **short template** as the default. Upgrade to the **full template** (explicit pros/cons per option) only when there are 3+ complex alternatives worth documenting.
3. **Status:** Every ADR must include YAML frontmatter with a `status` and `date`.
   - Valid statuses: `proposed`, `accepted`, `deprecated`, `superseded`.
   - If superseded, add a `superseded-by: NNNN-slug.md` field to the frontmatter.

### The Short Template

```md
---
status: accepted
date: YYYY-MM-DD
---

# Title (The Decision)

## Context and Problem Statement

What forces are at play? What problem prompted this?

## Considered Options

- Option 1
- Option 2

## Decision Outcome

Chosen option: **Option X**, because [justification].

## Evidence / Rationale (Optional)

Elaborate on the "why" if it requires more space than a single sentence.
```

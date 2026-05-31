**Architecture Decision Records (ADRs)**, originally proposed by Michael Nygard in 2011. They are the established, well-documented practice for exactly this: recording _why_ a decision was made, not just what was decided.

## The format (Nygard's original)

```markdown
# Title

## Status

Accepted | Deprecated | Superseded by ADR-NNN

## Context

What forces are at play? What problem prompted this?

## Decision

What was decided and why.

## Consequences

What becomes easier, harder, or must be watched after this decision.
```

Canonical sources (as of my training data):

- Nygard's original post: [cognitect.com/blog/2011/11/15/documenting-architecture-decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- **MADR** (Markdown Architectural Decision Records) — a more structured, widely-adopted variant: [adr.github.io/madr](https://adr.github.io/madr)

Convention is to store them as numbered files in `docs/adr/` or `docs/decisions/`:

```
docs/adr/
  0001-remove-zprofile.md
  0002-...
```

## My recommendation for your dotfiles

ADRs are a good fit here. The decisions in a dotfiles repo are _exactly_ the kind of thing ADRs capture well: low-frequency, non-obvious, easily forgotten reasoning that future-you (or an AI agent) will otherwise re-investigate from scratch. This very conversation is proof of that.

A lightweight MADR-style format (no tooling required, just numbered markdown files) is enough for a personal repo.

**MADR**, specifically its minimal/short template. Here's why:

## The practical difference

Nygard's original has 4 fixed sections. MADR adds one thing that matters: **"Considered Options"** with explicit pros/cons per option. Everything else is optional.

That one addition is exactly what your `.zprofile` decision needs — you evaluated `brew shellenv` vs. z4h's built-in setup, checked the Homebrew completion docs, cross-referenced the source code. Without a "Considered Options" section, that reasoning lives nowhere.

Nygard format would force you to cram all of that into "Context", which becomes a wall of prose.

## The other reasons

- MADR has an actively maintained spec and canonical template at [adr.github.io/madr](https://adr.github.io/madr) — a stable reference to link to, rather than a 2011 blog post.
- It has a **short template** (3–4 sections) and a **full template** (8+ sections). You use the short one for simple decisions, the full one when options genuinely need detailed comparison. You are never locked into verbosity.
- It is a superset of Nygard — any Nygard ADR is valid MADR.

## Recommendation

Use MADR's **short template** as your default. Upgrade to the full template only when there are 3+ real alternatives worth documenting.

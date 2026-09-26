---
trigger: model_decision
description: "Rules for writing READMEs and feature descriptions. Excludes API docs, changelogs, and migration guides."
---

# Documentation Conventions

The following rules of this section apply only to READMEs and feature descriptions. It does not apply to API docs, changelogs, or migration guides, where the file/function _is_ the topic.

- Do not guess the intended audience. Always ask the user to explicitly specify the target audience before drafting documentation.
- Avoid dense paragraphs; people usually scan instead of read. Default to highly scannable schematic structures.
- In any README, feature list, or "what you get" section, use **capability-first structure**: lead each section or entry with a single sentence stating what the reader _gains_ (the outcome), then list the tools or files that deliver it.
- Do not lead with file names or tool names. The reader's first question is "what does this do for me?", not "what is this file called?".
- Keep the capability sentence factual and specific - describe the actual outcome, not a vague quality ("consistent, automatically enforced code style on every commit" not "better code quality", etc.).
- Cross-reference when a tool or file has a dual role that affects more than one section (e.g. `.editorconfig` is listed in Editor configuration but also feeds Prettier's formatting config - note both).

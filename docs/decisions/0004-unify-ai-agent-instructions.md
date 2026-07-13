---
status: proposed
date: 2026-07-13
---

# Unify AI Agent Instructions into a Single Source of Truth

## Context and Problem Statement

The repository uses AI coding assistants (like GitHub Copilot in VS Code, and the Antigravity CLI). Both tools support global instructions to define conventions, but they require fundamentally incompatible formats:

1. **VS Code Copilot**: Relies on the `chat.instructionsFilesLocations` setting pointing to external folders. It strictly requires these files to end in `.instructions.md` and relies on YAML frontmatter (`applyTo: "**"`) to determine when to trigger them. It does not automatically consume `AGENTS.md`.
2. **Antigravity CLI**: Automatically consumes `~/.gemini/AGENTS.md`, but it requires a plain Markdown file and does not use YAML frontmatter for matching.

Because of this, there is no official "single file" solution that both VS Code and Antigravity can consume natively out of the box without duplicate maintenance. We need a single source of truth for global AI instructions.

## Considered Options

- **Node.js Build Script (`chezmoi:sync`)**: Treat `User/prompts/*.instructions.md` as the source of truth, read them via a Node.js script, strip the YAML frontmatter, and concatenate them into `home/dot_gemini/AGENTS.md`.
- **Symlinks with Relaxed Rules**: Maintain one master file `~/.gemini/AGENTS.md` containing the YAML frontmatter, symlink `AGENTS.instructions.md` to it, and configure VS Code to read `~/.gemini`. This requires relaxing the strict rule forbidding YAML frontmatter in `AGENTS.md`.
- **Native Chezmoi Template**: Rename `home/dot_gemini/AGENTS.md` to a template (`AGENTS.md.tmpl`) and use Chezmoi's native `include` and `replaceAllRegex` functions to concatenate the `.instructions.md` files and strip frontmatter natively during `chezmoi apply`, without external Node scripts.
- **Pointer File ("see X files")**: Place a string in `AGENTS.md` telling the agent to read the VS Code instructions files. (Rejected because the agent would have to waste a tool call reading the files on every single conversation, adding latency and unreliability).

## Decision Outcome

Status: **Proposed**

(Decision to be finalised later).

## References

- https://code.visualstudio.com/docs/agent-customization/custom-instructions
- https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions
- https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models
- https://docs.github.com/en/copilot/how-tos/copilot-on-github/set-up-copilot/configure-access-to-ai-models
- https://github.com/agentsmd/agents.md
- https://github.com/agentsmd/agents.md/issues/10
- https://github.com/agentsmd/agents.md/issues/153
- https://github.com/agentsmd/agents.md/issues/8
- https://github.com/agentsmd/agents.md/issues/9
- https://github.com/agentsmd/agents.md/issues/91
- https://www.google.com/search?q=github+copilot+use+api+from+another+ai+model

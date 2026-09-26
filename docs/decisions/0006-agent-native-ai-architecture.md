---
status: accepted
date: 2026-09-25
---

# Agent-native (Antigravity) AI architecture migration

## Context and problem statement

I used to maintain both GitHub Copilot, which had granular `.instructions.md` files, and Antigravity, which forced a monolithic `AGENTS.md` file.
It was tedious trying to manually synchronize them because I couldn't easily port Copilot's granular approach to Antigravity.
However, once I decided to abandon Copilot entirely and commit solely to Antigravity, the manual synchronization issue disappeared.
This left the monolithic `AGENTS.md` file as the actual critical bottleneck.
It caused severe prompt bloat and context drift because every instruction fired for every task.
I needed to solve this by making the most out of Antigravity's capabilities to have a more granular and modular AI architecture.

## Decision drivers

- I need to prevent prompt bloat and context drift by ensuring instructions only fire when relevant.
- I must dismantle the monolithic `AGENTS.md` file into a modular structure.
- I want to fully leverage Antigravity's modern capabilities for granular context management.

## Decision outcome

I migrated the monolithic `AGENTS.md` into granular Antigravity Rules and Skills to fully leverage its modern, modular capabilities.
During this architectural migration, I also took the opportunity to aggressively clean up and streamline the actual instruction content, removing redundant or paradoxical rules to further reduce cognitive load on the agent.

### 1. Granular Antigravity Rules

I split the monolithic instructions into granular rules utilizing tags like `always_on` and `model_decision`.
This ensures that the agent only loads these specific rules into context when they are actually relevant to the task.

### 2. Portable open-standard Skills

I extracted complex workflows into independent, portable open-standard Skills to further modularize the architecture.
This allows Antigravity to dynamically load specialized instructions and scripts on demand.

## Consequences

- **Positive:** Significant reduction in token usage per agent invocation due to targeted context loading.
- **Positive:** Improved agent focus and reduced hallucinations or context drift by eliminating irrelevant background instructions.
- **Positive:** Easier maintenance and versioning of AI instructions in logical, modular components.
- **Negative:** Increased initial setup complexity to properly configure the semantic matching patterns and YAML frontmatter for each rule and skill.

## References

- [Antigravity Rules Documentation](https://antigravity.google/docs/rules.md)
- [Antigravity Skills Documentation](https://antigravity.google/docs/skills.md)

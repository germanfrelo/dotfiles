---
name: evaluate-ai-instructions
description: Evaluates AI instruction/prompt files for issues that would cause an LLM to produce poor, inconsistent, or unexpected results. Use when auditing *.instructions.md files, AGENTS.md, or any AI instruction files to ensure high LLM performance.
---

# Evaluate AI Instructions

This skill provides expert AI prompt engineering evaluation to identify issues that degrade LLM performance, such as contradictions, ambiguities, persona inconsistencies, high cognitive load, and missing semantic coverage.

## When to use this skill

- Use this when the user asks to audit or evaluate AI instructions, such as `*.instructions.md`, `AGENTS.md`, or any other prompt or instruction files meant for an LLM.
- This is helpful for ensuring that rules and conventions do not confuse the LLM or cause unexpected behavior.

## How to use it

When evaluating an AI instruction file, follow these steps and guidelines:

1. **Read the file**: Use the `view_file` tool to read the target instruction file.
2. **Evaluate against the quality bar**:
   - Only report issues you are highly confident are real and materially harmful.
   - Do NOT report speculative, stylistic, or low-impact nits.
   - If evidence is weak or ambiguous, do not include that finding.
   - It is valid to return no issues in any or all categories when the prompt is already strong.
   - The relevant text should be a whole phrase from the prompt.
   - Prefer less diagnostics over more, especially if the additional ones are not critical.
3. **Perform the required analyses** (report only if there is strong evidence):
   - **Contradictions**: Find instructions that directly conflict with each other. Explain exactly WHY they conflict and what behavior the model would exhibit.
   - **Ambiguity**: Find vague or underspecified instructions that a model could interpret in multiple ways. Explain the different possible interpretations and suggest a concrete rewrite.
   - **Persona Consistency**: Find places where the expected tone, personality, or role contradicts itself. Explain the specific mismatch.
   - **Cognitive Load**: Find overly complex instruction patterns (deeply nested conditions, too many competing priorities, unclear precedence). Flag any "conversational persuasion"—rules that attempt to justify themselves or persuade the AI rather than just stating the imperative constraint. Explain why they increase cognitive load or are hard for a model to follow.
   - **Semantic Coverage**: Find scenarios or edge cases the prompt doesn't address, where the model would have to guess. Explain what could go wrong.
4. **Report findings**: Consolidate your findings and present them clearly to the user, typically in a structured Markdown artifact.

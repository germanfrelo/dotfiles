# AI Instruction Evaluation Examples

This document provides concrete examples of common AI instruction flaws to help anchor the evaluation criteria in `SKILL.md`.

## 1. Conversational Persuasion (Cognitive Load)

Rules should state imperative constraints. They should not waste tokens trying to persuade the AI or justify why the rule exists.

**Bad (High Cognitive Load & Conversational):**

> "Always use the `date-fns` library instead of `moment.js` because `moment.js` is bloated, no longer maintained, and it produces a much larger bundle size which we want to avoid."

**Good (Imperative Constraint):**

> "Use `date-fns` instead of `moment.js`."

_Why it's bad:_ The AI does not need to be convinced to follow the rule. The "because" clause is fluff that dilutes the actionable constraint.

## 2. Ambiguity

Rules should be deterministic. Vague words like "clean", "proper", or "modern" lead to unpredictable LLM outputs.

**Bad (Ambiguous):**

> "Write clean and modern React components."

**Good (Deterministic):**

> "Write React components as functional components using Hooks. Do not use class components."

_Why it's bad:_ "Clean" and "modern" are subjective. Different LLMs (or different temperatures) will interpret those words differently. The good example specifies exactly what constitutes the required pattern.

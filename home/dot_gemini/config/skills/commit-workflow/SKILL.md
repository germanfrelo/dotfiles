---
name: commit-workflow
description: "Reviews changes, proposes atomic commits, and writes commit messages. Use when staging changes, drafting commit messages, or committing to a Git repository."
---

# Commit Workflow

1. **Inspect repository state**: Run `git status`. If the working tree and index are clean, stop immediately and notify the user.
2. **Plan atomic commits**: Run `git status -vv`. Handle the state according to two scenarios:
   - **2.a. Changes exist only in the index or only in the working tree**: Painstakingly inspect the diff line-by-line to ensure the target commit contains only one logical change. If unrelated changes are mixed, propose how to split them across atomic commits.
   - **2.b. Changes exist in both the index and the working tree**: Painstakingly and surgically isolate changes until the staged index contains exactly one logical change and unstaged changes remain separate.
3. **Draft the commit message**: Run `git log -n 10` to inspect recent commit style and conventions (ignoring automated commits like dependency updates or version bumps), then draft the body and title:
   - **Body**:
     - **Structure**: Structure the body cause-first (state the trigger, origin, or cause first, followed by the resolution and rationale).
     - **Composition**: Use prose paragraphs for a single cohesive change or a flat bulleted list for parallel changes of equal weight.
     - **Formatting**: Use semantic line breaks (write each logical sentence as a single unbroken line, separated by blank lines between paragraphs) unless the repository explicitly configures a commit linter or guidelines enforcing a body line length limit. Format list items as single unbroken lines ending with a full stop.
   - **Title**:
     - **Derivation**: Synthesize the overarching intent from the drafted body; focus on the high-level outcome rather than mechanical implementation details.
     - **Format**: Follow strictly `type: Title` (or `type(scope): Title` when scope is used: lowercase type and scope, uppercase first letter after the colon).
     - **Scope**: Omit the scope unless required by repository rules; use repository history strictly to resolve scope naming conventions.
     - **Length**: Ideal target: ≤50 characters. Hard ceiling: 72 characters.
     - **Alternatives**: Provide up to 2 alternative titles.
4. **Present and execute**:
   1. Present the staging plan, the primary commit message, and any title alternatives, and wait for explicit user approval before running `git commit`.
   2. After approval, run `git commit` as a standalone command without chaining. Never push unless explicitly requested.
   3. Verify the recorded commit using `git log -1`.

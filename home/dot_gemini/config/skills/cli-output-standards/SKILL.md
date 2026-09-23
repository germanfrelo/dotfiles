---
name: cli-output-standards
description: Use this skill when the user asks the agent to write, refactor, or generate Node.js scripts, shell scripts, or any code that produces console output. It enforces a strict icon-based formatting system for terminal logs.
---

# CLI Output Standards

This skill provides the runbook for formatting terminal output, ensuring that all scripts produce scannable, standardized logs using a consistent `Emoji + State/Action` prefix.

## Steps

When writing or editing CLI output logic, follow these steps to format the logs:

1. **Determine the output state**: Identify what the log represents and apply the exact corresponding icon:
   - `✅` **Success / OK / Up-to-date**: A check passes or an operation succeeds.
   - `⏭️ ` **Skipped / Ignored / Dry-run**: Intentionally bypassing an item (Requires trailing space).
   - `⚠️ ` **Warning / Non-fatal error**: A check fails but the script continues (Requires trailing space).
   - `❌` **Fatal Error / Operation failed**: An operation aborts or API fails.
   - `🔄` **Action / Updating / Fetching data**: Iterating or modifying values.
   - `➕` **New item added / Created**: Generating a new resource.
   - `🗃️ ` **Archived / State change**: A lifecycle state change (Requires trailing space).

2. **Align sub-items**: When printing status for sub-items (like checking multiple files within a repo), align the status icons vertically by padding the prefix with spaces.

   ```text
     LICENSE:      ✅ ok
     package.json: ⏭️  not found (skipping)
   ```

3. **Simplify object diffs**: Do not print bulky `[old] -> [new]` diffs for large JSON objects or arrays. Instead, simply report that the field was updated.

   ```text
       🔄 updated _derived.generalSettings
   ```

4. **Format progress indicators**: Use a hyphen for list progress instead of an icon to prevent visual fatigue.

   ```text
   - [1/22] repo-name
   ```

5. **Verify the output**: Before finalizing the task, run the script (or run a dry-run) in the terminal to verify that the icons render correctly and that all colons are perfectly aligned vertically.

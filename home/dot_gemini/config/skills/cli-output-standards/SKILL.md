---
name: cli-output-standards
description: "Enforces a standardized icon-based formatting system for terminal logs. Use when writing, refactoring, or generating Node.js scripts, shell scripts, or CLI code that produces console output."
---

# CLI Output Standards

1. **Select state icon**: Prefix each status log with its corresponding icon followed by a space:
   - `✅` **Success / OK / Up-To-Date**: Check passes or operation succeeds.
   - `⏭️` **Skipped / Ignored / Dry-Run**: Item is intentionally bypassed or dry-run.
   - `⚠️` **Warning / Non-Fatal Error**: Check fails but execution continues.
   - `❌` **Fatal Error / Operation Failed**: Operation aborts or API call fails.
   - `🔄` **Action / Updating / Fetching**: Value is modified or resource is fetched.
   - `➕` **Created / Added**: New resource is generated.
   - `🗃️` **Archived / State Change**: Resource lifecycle state changes.

2. **Align sub-item columns**: When logging multiple sub-items (e.g., per-file checks within a repository), pad labels with trailing spaces so status icons align vertically:

   ```text
     LICENSE:      ✅ ok
     package.json: ⏭️ not found (skipping)
   ```

3. **Summarize object updates**: Report updated field names instead of printing bulky `[old] -> [new]` diffs for large objects or arrays:

   ```text
       🔄 updated _derived.generalSettings
   ```

4. **Format progress counters**: Prefix batch progress lines with a plain hyphen (`- [1/22] repo-name`) instead of an emoji to avoid visual noise.

5. **Verify terminal alignment**: Run the script (or `--dry-run`) in the terminal to confirm icons and colons align vertically.

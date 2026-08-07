---
name: Safe deletion
description: "Deletion safety: prefer trash over rm for all file and directory removal commands"
applyTo: "**"
---

- Always use `trash` (not `rm`) for file and directory deletions.
- Use `rm` only when authoring scripts or CI pipelines.
- If `trash` fails, propose the `rm` alternative and wait for explicit approval before executing.
- If deleting via globs/wildcards, list the matching files and wait for explicit approval before executing.
- Never run `rm` on system or root home paths (`/`, `/bin`, `/etc`, `$HOME`, `~`). Refuse immediately; there is no override.

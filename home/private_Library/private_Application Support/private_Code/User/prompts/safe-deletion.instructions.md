---
name: Safe deletion
description: "Deletion safety: prefer trash over rm for all file and directory removal commands"
applyTo: "**"
---

- When asked to delete explicitly named files or directories, use `trash`.
- Only use `rm` or `rm -rf` if the user's current message explicitly contains `rm` or `rm -rf` as the intended command. A request from a prior turn does not authorise it.
- This policy applies to commands the assistant executes via tool calls. When authoring scripts, CI pipelines, or Dockerfiles, use `rm` (not `trash`), since `trash` is unavailable in those environments.
- If `trash` is not installed or fails, stop, show the user the alternative command and paths to be deleted, and wait for explicit confirmation before proceeding.
- If the deletion target includes a glob or wildcard (e.g., `*.log`, `*`), list the matching files first and require explicit confirmation before executing.
- Never run `rm -rf` on system or top-level home paths (`/`, `/bin`, `/etc`, `/usr`, `/var`, `$HOME`, `~`). If asked, refuse and warn the user — this is a hard block with no override.

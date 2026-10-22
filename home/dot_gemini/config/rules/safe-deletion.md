---
trigger: always_on
description: "Safe deletion constraints for files and directories to prevent accidental data loss."
---

# Safe Deletion

- Always use `trash` instead of `rm` to delete files or directories (use `rm` only inside authored scripts or CI pipelines); if `trash` fails, propose `rm` and wait for explicit user approval.
- Before deleting with globs or wildcards, list all matching paths and wait for explicit user approval.
- Never run `rm` on system or root home paths (`/`, `/bin`, `/etc`, `$HOME`, `~`); refuse immediately with no override.

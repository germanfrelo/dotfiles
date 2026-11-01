---
status: accepted
date: 2026-10-31
---

# Ignore all VS Code workspace files by default

## Context and Problem Statement

Visual Studio Code stores project configurations in `.vscode/` (`extensions.json`, `launch.json`, `settings.json`, `tasks.json`, `*.code-snippets`) and workspace files (`*.code-workspace`).
These files frequently mix shared team standards (such as recommended extensions) with personal developer preferences (such as workspace color customizations or local debug targets).
When tracked in Git, personal tweaks clutter commit history and can unintentionally impose one developer's environment onto teammates.
Furthermore, standard community templates (such as the official [GitHub VisualStudioCode template](https://raw.githubusercontent.com/github/gitignore/refs/heads/main/Global/VisualStudioCode.gitignore)) un-ignore `.vscode/` files by default, causing Git to treat local editor tweaks as uncommitted changes across every repository on the machine.

How can developers keep personal editor preferences private across all projects without cluttering Git history or creating friction for teammates?

## Decision Drivers

- Keep personal editor preferences and workspace tweaks local so they never appear in Git.
- Prevent accidental commits of machine-specific paths, local debug targets, or private credentials stored in editor configs.
- Keep project repositories editor-agnostic so team members can use whichever code editor they prefer.
- Anchor code quality enforcement in standard project toolchains and automated pipeline checks rather than local editor files.
- Provide a clean, predictable Git ignore setup that works consistently across both personal and team repositories.

## Considered Options

- Option 1: Ignore all VS Code workspace files globally
- Option 2: Ignore all VS Code workspace files globally _except_ `extensions.json`, `launch.json`, `tasks.json`, and `*.code-snippets`
- Option 3: Ignore all VS Code workspace files globally _except_ `extensions.json`, `launch.json`, `settings.json`, `tasks.json`, and `*.code-snippets` (upstream template defaults)

## Decision Outcome

Chosen option: "Option 1: Ignore all VS Code workspace files globally", because:

1. **All workspace files remain private by default**: Personal settings (such as workspace color customizations), tasks, and launch targets exist on disk without dirtying `git status`.
2. **Eliminates brittle tracking exception rules**: Ignoring everything by default avoids maintaining opinionated exception rules (`!`) that treat every local task or debug configuration as a shared team asset.
3. **Preserves existing team files without regression**: Existing tracked team files in shared repositories continue to work normally, while sharing a new configuration file remains a conscious, intentional one-time action (`git add -f`).

### Consequences

- **Good**, because personal editor settings (such as workspace color customizations) and local workspace files exist on disk without cluttering Git history.
- **Good**, because accidental commits of machine-specific paths, local debug targets, or private credentials stored in editor configs are prevented by default.
- **Good**, because project repositories remain strictly editor-agnostic, ensuring code quality enforcement relies on canonical project toolchains and automated pipeline checks rather than tracked editor settings.
- **Good**, because existing tracked team configuration files continue working without disruption.
- **Neutral**, because committing a new team configuration file for the first time requires an intentional force-add (`git add -f`).

### Confirmation

- Confirmed through Git CLI testing that untracked files inside `.vscode/` and `*.code-workspace` files are ignored by default and prompt for an explicit flag when adding them.
- Verified that existing team configuration files in shared repositories remain tracked and continue to stage and diff normally without `-f`.
- Audited local development repositories to ensure `.vscode/` workspace files remain untracked by default while local customizations remain active.

## Pros and Cons of the Options

### Option 1: Ignore all VS Code workspace files globally

- **Good**, because personal settings, custom tasks, launch configurations, and snippets remain private by default.
- **Good**, because it completely eliminates accidental commits of personal editor tweaks and local workspace files.
- **Good**, because existing tracked team configuration files continue working without disruption.
- **Good**, because the global Git ignore setup is simple and requires only two unambiguous rules.
- **Neutral**, because adding a new team file for the first time requires an intentional `git add -f`.

### Option 2: Ignore all VS Code workspace files globally _except_ `extensions.json`, `launch.json`, `tasks.json`, and `*.code-snippets`

- **Good**, because team configuration files can be added without an explicit force-add command.
- **Bad**, because it assumes every task, debug launch profile, or snippet created by a developer is intended for the team repository.
- **Bad**, because personal debugging targets (such as local ports) or local utility tasks immediately dirty `git status` as untracked files.
- **Bad**, because maintaining multiple exception rules adds unnecessary configuration complexity.

### Option 3: Ignore all VS Code workspace files globally _except_ `extensions.json`, `launch.json`, `settings.json`, `tasks.json`, and `*.code-snippets` (upstream template defaults)

- **Good**, because it matches the default rules generated by popular community templates (such as the official [GitHub VisualStudioCode template](https://raw.githubusercontent.com/github/gitignore/refs/heads/main/Global/VisualStudioCode.gitignore)).
- **Bad**, because it globally un-ignores `.vscode/settings.json` and other editor configurations across every repository on the machine.
- **Bad**, because any workspace color customization, personal preference, or local task immediately appears as an uncommitted change in Git.
- **Bad**, because it mixes shared team tooling with individual developer preferences across every repository.

## More Information

### Project governance categories

| Project category                                        | `.vscode/settings.json` policy                                               | `.gitignore` scope                                                          | Workspace color customizations                                        |
| :------------------------------------------------------ | :--------------------------------------------------------------------------- | :-------------------------------------------------------------------------- | :-------------------------------------------------------------------- |
| **Personal private projects**                           | Untracked.                                                                   | Global ignore file (`~/.config/git/ignore`).                                | Defined in local untracked `.vscode/settings.json`.                   |
| **Personal public open-source projects**                | Untracked (shared team files tracked).                                       | Global ignore file. Repository `.gitignore` remains editor-agnostic.        | Defined in local untracked `.vscode/settings.json`.                   |
| **Team projects (internal architecture control)**       | Untracked (shared template committed if helpful; pipeline enforces quality). | Defensive inclusion of `.vscode/*` in project `.gitignore` for team safety. | Defined in local untracked `.vscode/settings.json`.                   |
| **External or legacy projects (rigid upstream policy)** | Tracked by upstream team.                                                    | Governed by upstream team.                                                  | Isolated via untracked local workspace file (`local.code-workspace`). |

### Workarounds for rigid upstream repositories

Because Git ignore rules only apply to untracked files, personal settings cannot be ignored via `.gitignore` in repositories where `.vscode/settings.json` is already tracked upstream.

Because `*.code-workspace` is ignored globally, developers can isolate local customizations without modifying tracked repository files:

1. Create a local workspace file in the project root (`local.code-workspace`):

   ```json
   {
     "folders": [
       {
         "path": "."
       }
     ],
     "settings": {}
   }
   ```

2. Open the project with `code local.code-workspace` instead of `code .`.

### Related decisions

- [ADR 0002: Prioritize VS Code Settings Sync over chezmoi](/docs/decisions/0002-prioritize-vscode-settings-sync-over-chezmoi.md)

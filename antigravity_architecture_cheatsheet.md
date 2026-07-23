# Antigravity Architecture & Dotfiles Cheatsheet

This document outlines how data is shared and separated between the **Antigravity CLI** (`agy`) and the **Antigravity 2.0 Desktop App**, and provides recommendations for safely cleaning up and tracking configurations.

## 🔗 Shared Globally (The Ecosystem Core)

Both the CLI and the Desktop App are built on the same "Agent Harness" backend. They share core configurations located in the root of `~/.gemini/`:

- **`~/.gemini/settings.json`**: Global preferences (AI Model selection, authentication, theme flags).
- **`~/.gemini/AGENTS.md`**: Your global personal memory and custom agent rules.
- **`~/.gemini/config/projects/`**: Workspace configurations. A project created in the CLI is immediately available in the App, and vice versa.
- **`~/.gemini/config/plugins/` & `mcp_config.json`**: Custom Skills, Rules, and Model Context Protocol (MCP) servers are shared seamlessly.

## ✂️ Unlinked (Interface-Specific State)

While they share the backend, they maintain entirely separate storage for active sessions to prevent collision.

### Antigravity CLI (`~/.gemini/antigravity-cli/`)

- **`settings.json`**: Terminal-specific configurations (verbosity, allowed shell commands).
- **`title.sh` & `statusline.sh`**: Your custom UI scripts for the terminal interface.
- **`conversations/` & `brain/`**: The SQLite databases (`.db`) and Markdown artifacts generated strictly during CLI usage.
- **`conversation_summaries.db`**: The SQLite index tracking your CLI sessions.

### Antigravity 2.0 Desktop App (`~/.gemini/antigravity/`)

- **`conversations/` & `brain/`**: The SQLite databases and Markdown artifacts generated during (or migrated into) Desktop App usage.
- **`agyhub_summaries_proto.pb`**: A highly-optimized Protobuf index tracking Desktop sessions (rebuilt automatically during migration).
- **`antigravity_state.pbtxt`**: Desktop-specific onboarding, UI states, and migration flags.

---

## 🧹 Safe Cleanup Guide

If you are fully transitioning your existing sessions to the Desktop App and want to reclaim disk space, you can safely clean up the CLI's old storage **without breaking the Desktop App**:

1. **Wait and Verify**: Ensure all your old chats load correctly in the Desktop App.
2. **Purge CLI Data**: You can safely delete the contents of:
   - `~/.gemini/antigravity-cli/conversations/` (deletes legacy `.db` session files)
   - `~/.gemini/antigravity-cli/brain/` (deletes legacy artifacts)
3. **Do NOT Delete**:
   - `~/.gemini/antigravity-cli/settings.json` (keep if you still want to use `agy` occasionally)
   - `~/.gemini/config/` (this would break both tools!)

---

## 🛠️ Chezmoi Dotfiles Recommendations

Your current `.chezmoiignore` is great, but as you explore Antigravity 2.0, you should track a few more ecosystem files:

### Currently Tracked (Good!)

- `~/.gemini/AGENTS.md`
- `~/.gemini/settings.json`
- `~/.gemini/antigravity-cli/settings.json`
- `~/.gemini/antigravity-cli/statusline.sh`
- `~/.gemini/antigravity-cli/title.sh`

### Recommended Additions

Consider adding these to Chezmoi by un-ignoring them (e.g., `!.gemini/config/...`):

1. **`~/.gemini/config/config.json`**
   - Tracks your Desktop App UI settings.
2. **`~/.gemini/config/mcp_config.json`**
   - Highly recommended if you set up MCP servers (like the Chrome DevTools plugin or custom local servers).
3. **`~/.gemini/config/plugins/**`\*\* _(Optional but recommended)_
   - If you ever write custom Skills or Rules (the files ending in `SKILL.md` or `RULE.md`), they live here. Tracking this folder ensures your custom agent capabilities sync across machines.
4. **`~/.gemini/config/projects/**`\*\* _(Situational)_
   - Only track this if your repository paths (e.g., `/Users/germanfrelo/repos/...`) are identical across all your Macs. If paths vary per machine, leave this ignored.

# Configuration & Script Comment Style Guide

A structured standard for top-of-file docblock banners, section dividers, inline comments, and alert callouts across configuration files and shell scripts.

## Scope & Applicability

This style guide applies across all repositories to:

- **`#`-commented configuration files**: INI (`.gitconfig`), TOML (`chezmoi.toml`), YAML (`dependabot.yml`, GitHub Actions workflows), and properties/options files (`ncdu/config`, `.npmrc`, `ghostty/config`).
- **Ignore & exclusion files**: Git ignore files (`.gitignore`, `ignore`), Prettier ignore (`.prettierignore`), chezmoi ignore (`.chezmoiignore`), and Git blame ignore lists (`.git-blame-ignore-revs`).
- **Shell scripts & Git hooks**: Bash and Zsh executable scripts, installer scripts (`.chezmoiscripts/`), and Git hooks (`.husky/*`).
- **`//`-commented structured configs**: JSON with Comments (`.markdownlint-cli2.jsonc`).
- **JavaScript configuration modules**: Node.js ES module configuration files (`prettier.config.js`, `svgo.config.js`).

### Exemptions

The following files are explicitly exempt from custom docblock banners and section dividers:

- **Single-value / machine-parsed version files**: `.nvmrc`, `.node-version`, and similar tools where naive parsers expect a single token and can break on comments.
- **Strict JSON files**: Files with the `.json` extension (including VS Code snippet files in `snippets/*.json`) where standard JSON (RFC 8259) forbids comments.
- **CLI-serialized configuration files**: Files that are programmatically parsed, rewritten, and re-serialized by external CLI tools (e.g. `gh/config.yml`), which can strip or reposition custom top-of-file banners.
- **Wizard-generated configurations**: Large machine-generated files managed by interactive setup wizards (e.g. `~/.p10k.zsh`).

---

## Comment Hierarchy Overview

All comments belong to one of four visual hierarchy levels or to the alert/callout category:

| Level                 | Syntax                                                                 | Visual Weight   | Usage                                                                                                   |
| :-------------------- | :--------------------------------------------------------------------- | :-------------- | :------------------------------------------------------------------------------------------------------ |
| **L1 File Docblock**  | 40-character `=` banner (`# ========================================`) | Heavy framing   | File header with `<Scope/Tool> configuration` title, canonical documentation URL, and optional context. |
| **L2 Section**        | 6 hyphens + `UPPERCASE` (`# ------ SECTION ------`)                    | Medium divider  | Major thematic group or top-level configuration domain.                                                 |
| **L3 Subsection**     | 3 hyphens + `Title Case` (`# --- Subsection ---`)                      | Light divider   | Specific tool feature, sub-domain, or package category within an L2 section.                            |
| **L4 Inline / Prose** | Plain `# Sentence case.` and `# Ref. <URL>`                            | Minimal chrome  | Explanatory comments, rationale, and specific documentation references.                                 |
| **Callout / Alert**   | `# <EMOJI> <TYPE>: <Imperative sentence>.`                             | High visibility | Constraints, prohibitions, warnings, and non-configuration sentinel notices.                            |

---

## Rules & Conventions

### Rule 1: L1 File Docblock Banners

Every managed configuration file and script must begin with a top-of-file docblock framed by exactly 40 `=` characters.

#### Syntax & Structure

```ini
# ========================================
# <Scope/Tool> configuration
# <Canonical Documentation URL>
# ========================================
```

#### Rules

- **Delimiter length**: The delimiter must consist of a `#` followed by a space and exactly 40 `=` characters (`# ========================================`), providing a consistent horizontal anchor.
- **Title phrasing**: Use a complete noun phrase ending in `configuration` (or `workflow`, `script`, `hook`). Never use the redundant filler word `file`.
- **Scope qualification**: When multiple files configure the same tool at different layers, qualify the scope explicitly (e.g. `Global Git configuration` vs. `Project Git ignore configuration`, or `User npm configuration` vs. `Project npm configuration`).
- **Template neutrality**: Never include the word `template` in rendered `#` comments. In chezmoi `.tmpl` files, the comment renders into destination files on disk, where the target is not a template.
- **Canonical documentation URL**: Always provide a bare, direct URL to the official reference documentation or manpage immediately below the title. Omit labels like `Documentation:` or `Ref:`.
- **Placement**: Place the banner at line 1. If the file requires an interpreter shebang (`#!/usr/bin/env bash`) or linter directive (`# shellcheck shell=zsh`), place the directive first, followed by a blank line, and then the docblock banner.

#### Language-Specific Adaptations

- **JSON with Comments (JSONC)**: Replace `#` with `//` (`// ========================================`).
- **JavaScript configuration files (`*.config.js`)**: Place a `// ========================================` banner at the top of the file, followed by a standard JSDoc `/** @type {...} */` annotation immediately above the configuration object.

---

### Rule 2: L2 Section & L3 Subsection Headers (2:1 Ratio)

When a configuration file contains multiple functional areas, structure them using a 2:1 hyphen symmetry ratio.

#### Syntax & Structure

```ini
# ------ SECTION NAME ------

# --- Subsection Name ---
```

#### Rules

- **L2 Section headers**: Enclose the section title in 6 hyphens on each side using `UPPERCASE` letters (`# ------ SECTION ------`).
- **L3 Subsection headers**: Enclose the subsection title in 3 hyphens on each side using `Title Case` (`# --- Subsection ---`).
- **2:1 Ratio rationale**: Giving parent sections exactly twice the hyphen count of subsections (`6` vs. `3`) alongside distinct typographical casing (`UPPERCASE` vs. `Title Case`) creates a clear visual hierarchy that prevents subsections from blending into adjacent prose comments.

---

### Rule 3: L4 Explanatory Comments & Reference Citations

In-file explanatory prose and documentation references follow a standardized format:

- **Prose explanations**: Write clear, grammatically complete sentences in sentence case, ending with a full stop.
- **Documentation citations**: Prefix URL citations with `# Ref.` followed by a single space and the canonical URL.

```ini
# Normalize line endings to LF on commit.
# Ref. https://git-scm.com/docs/git-config#Documentation/git-config.txt-coreautocrlf
```

---

### Rule 4: Callouts and Alerts

Use alert comments to highlight constraints, non-obvious design decisions, or destructive operations. Alert types align with the [GitHub Flavored Markdown Alerts](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts) taxonomy:

| Alert Label     | Emoji | Purpose                                           | Example                                         |
| :-------------- | :---- | :------------------------------------------------ | :---------------------------------------------- |
| **`NOTE`**      | `ℹ️`  | Useful context users should know when skimming.   | `# ℹ️ NOTE: Pattern applies recursively.`       |
| **`TIP`**       | `💡`  | Helpful advice for doing things better or faster. | `# 💡 TIP: Run 'z4h update' to update.`         |
| **`IMPORTANT`** | `❗️`  | Key constraint required to achieve a goal.        | `# ❗️ IMPORTANT: Do NOT set 'core.editor'.`     |
| **`WARNING`**   | `⚠️`  | Urgent information to avoid problems or misuse.   | `# ⚠️ WARNING: Do NOT add configuration here.`  |
| **`CAUTION`**   | `🛑`  | Advises about destructive risks or data loss.     | `# 🛑 CAUTION: Overwrites uncommitted changes.` |

#### Formatting Rules

- Place the emoji and uppercase alert label first, followed by a colon and a space (e.g. `# ⚠️ WARNING: <instruction>`).
- State the imperative action or prohibition immediately on the first line next to the label.

---

### Rule 5: `remove_*` and Sentinel File Blueprint

Chezmoi `remove_*` files and empty sentinel stubs (such as a dummy `~/.zshrc` used to detect rogue tool writes) are not configuration files; their purpose is enforcement or detection.

Every `remove_*` file must follow this exact 3-line blueprint:

```ini
# ⚠️ WARNING: Do NOT add configuration here or remove this file.
# The `remove_` prefix of this file instructs chezmoi to delete `<target>` if it exists, enforcing its absence.
# Decision: /docs/decisions/<NNNN>-<decision-slug>.md
```

#### Blueprint Rules

1. **Line 1 (Stop-sign)**: Use `# ⚠️ WARNING:` followed immediately by the active prohibition: `Do NOT add configuration here or remove this file.`
2. **Line 2 (Mechanism)**: Explicitly explain that `"The 'remove_' prefix of this file"` instructs chezmoi to delete the target on `chezmoi apply`, enforcing its absence.
3. **Line 3 (Governance)**: Link to the corresponding Architecture Decision Record that explains why the file is enforced absent.

# Backlog: ADR Tooling & Templates

Currently, I need to decide how to create new ADRs efficiently. Here is a breakdown of the two primary options: using a manual template file vs adopting `adr-tools`.

## Option 1: Manual Template (`0000-template.md`)

MADR explicitly recommends using actual template files. Having a dedicated template file (`0000-template.md`) in this directory provides frictionless creation: I can simply run `cp docs/decisions/0000-template.md docs/decisions/0005-my-new-decision.md` and immediately start filling in the blanks. The `0000` prefix keeps it cleanly pinned at the top of the directory.

## Option 2: `adr-tools`

`adr-tools` (specifically the canonical `npryce/adr-tools` repository on GitHub) is the most popular command-line toolkit for managing ADRs. It provides commands like `adr new` and `adr supersede` to automate the numbering, linking, and status updates of decision records.

### Pros & Cons

**Pros:**

- **Zero friction:** I never have to manually figure out "what number am I on?" or manually type out filenames with dashes.
- **Dependency Graphing:** When I supersede or amend decisions, the tool automatically cross-links them (e.g., updating the old file to say "Superseded by 0005").
- **Auto-indexing:** Generating the TOC is a single command.

**Cons:**

- **Another dependency:** I have to install it via Homebrew (`brew install adr-tools`) and ensure it's available on all my machines.
- **Default mismatch:** By default, `adr-tools` uses Michael Nygard's original 2011 format. To use MADR, I must override its default behavior by initializing a custom `templates/template.md` directory within the ADR folder.
- **Overkill for small scale:** The automated linking, superseding, and Table of Contents generation features are lifesavers in a corporate monorepo with 150+ decisions and large engineering teams. For a personal dotfiles repo with a handful of decisions, it solves problems I don't really have.

### How to Implement `adr-tools`

If chosen, the implementation steps are:

1. Run `brew install adr-tools` and add it to the Brewfile.
2. Run `adr init docs/decisions`.
3. Create the custom MADR template at `docs/decisions/templates/template.md`.

---
status: accepted
date: 2026-10-23
---

# Adopt Shuck as Unified Shell Script Toolchain

## Context and Problem Statement

The repository contains diverse shell scripts, including chezmoi Go template installers (`*.sh.tmpl`), interactive Zsh dotfiles (`.zshrc`, `.zshenv`), Git hooks (Husky scripts), and upstream vendor CLI scripts.

Historically, shell script linting and formatting were coupled to the `stubbedev.shell-lsp` VS Code extension, which implemented ShellCheck-compatible diagnostics and `shfmt`-compatible formatting in Go.

This editor-coupled setup suffered from several failure modes:

1. **Editor Coupling and Lack of CLI Workflow**: Relying on a VS Code extension provided no standalone CLI executable for CI/CD and pre-commit hooks, while silently swallowing formatting parse errors without surfacing them in VS Code's diagnostic problem panel.
2. **Prettier Incompatibility**: Prettier does not support shell scripts and throws syntax errors when attempting to parse them, requiring shell files to be routed through a dedicated toolchain while keeping repository-wide formatting orchestration (`npm run format`) cohesive.
3. **Dialect Fragmentation**: Shell scripts in dotfiles often lack file extensions and shebangs. Standard linters like ShellCheck lack native Zsh parsing support (reporting `SC1071`), while chezmoi template delimiters (`{{- ... }}`) trigger syntax errors under standard shell parsers.
4. **Formatting Configuration Drift**: Configuring formatting across multiple standalone tools resulted in non-standard configurations (such as `space-redirects = true` from `shfmt -sr`), creating visual inconsistencies with standard POSIX redirection syntax.

How should the repository lint, format, and validate shell scripts across both developer workstations and automated Git hooks without depending on Prettier or editor-bound extensions?

## Decision Drivers

- Must provide a single, unified command-line toolchain for both linting and formatting shell scripts.
- Must eliminate all Prettier dependencies for shell script formatting while keeping project-wide `npm run format` workflows cohesive.
- Must provide native, first-class support for both Bash and Zsh dialects without requiring inline `# shellcheck shell=...` directives in startup dotfiles.
- Must parse chezmoi template scripts (`*.sh.tmpl`) without failing on Go template delimiters.
- Must standardize formatting on POSIX unspaced redirection (`>/dev/null 2>&1`) and tab indentation.
- Must protect upstream vendor scripts ([`home/dot_gemini/antigravity-cli/*.sh`](/home/dot_gemini/antigravity-cli)) from formatting drift while keeping them linted.
- Must execute with sub-second latency inside Git pre-commit hooks (`lint-staged`).
- Must provision deterministically via Homebrew ([`Brewfile`](/Brewfile)) and orchestrate cleanly via npm scripts ([`package.json`](/package.json)).

## Considered Options

- **Option 1: `ewhauser/shuck` (`shuck-cli`) via Homebrew** (Chosen).
- **Option 2: Native System Binaries (`shellcheck` + `shfmt` via Homebrew)**.
- **Option 3: Pure Node.js / WebAssembly Engine (`@wasm-fmt/shfmt` + `shellcheck-wasm` with bespoke JS runner)**.
- **Option 4: Monolithic Editor Extension (`stubbedev.shell-lsp` in VS Code)**.

## Decision Outcome

Chosen option: **Option 1: `ewhauser/shuck` (`shuck-cli`) via Homebrew**, because it provides a single high-performance Rust executable that natively combines dialect-aware static analysis, code formatting, and Language Server Protocol support into a turnkey CLI.
It provides declarative file-based configuration via [`.shuck.toml`](/.shuck.toml), removing the requirement for inline dialect comments and orchestrating seamlessly with `lint-staged` and Homebrew.

### Tooling Provisioning and Task Orchestration

- **Homebrew Provisioning**: Declared in [`Brewfile`](/Brewfile) via `tap "ewhauser/tap"` and `brew "shuck-cli"`. Developers trust the tap once via `brew trust ewhauser/tap` and install project dependencies via `brew bundle --file=./Brewfile`.
- **npm Scripts Composition**: In [`package.json`](/package.json), `format` and `format:check` compose Prettier (for JS, JSON, Markdown, YAML) and Shuck (for shell scripts) sequentially.
  - `format`: `"prettier --write . && npm run format:shell"`.
  - `format:check`: `"prettier --check . && npm run format:shell:check"`.
  - `format:shell`: Formats tracked shell files via `git ls-files -z` and `xargs -0 env SHUCK_EXPERIMENTAL=1 shuck format`.
  - `lint:shell`: Lints tracked shell files via `git ls-files -z` and `xargs -0 shuck check`.
- **Pre-commit Hooks**: In [`package.json`](/package.json), `lint-staged` routes staged shell scripts (`{**/*.sh,**/*.sh.tmpl,.husky/!(_)*,**/*zshrc,**/*zshenv}`) to `env SHUCK_EXPERIMENTAL=1 shuck format` and `shuck check`.

### Formatting Standards and Redirection Syntax

- **Tab Indentation**: Configured in [`.shuck.toml`](/.shuck.toml) with `indent-style = "tab"`, matching the repository's root [`.editorconfig`](/.editorconfig) policy.
- **Switch-Case Indentation**: Configured in [`.shuck.toml`](/.shuck.toml) with `switch-case-indent = true` to indent `case` statement branch bodies.
- **POSIX Unspaced Redirections**: Omits `space-redirects = true` from [`.shuck.toml`](/.shuck.toml), allowing `shuck format` to default to universal POSIX (IEEE Std 1003.1) and Google Shell Style Guide unspaced redirection syntax (`>/dev/null 2>&1`, `>file`, `<<'EOF'`). Spaced redirects (`> /dev/null`) introduced by commit `8ced2fa` were reverted across all shell scripts.
- **EditorConfig Separation**: Formatting settings reside canonically in [`.shuck.toml`](/.shuck.toml) because `shuck-cli` does not read `.editorconfig`.

### Dialect Mappings and Chezmoi Template Support

Configured under `[per-file-shell]` in [`.shuck.toml`](/.shuck.toml):

- `"**/*.sh.tmpl" = "bash"`: Instructs Shuck's parser to analyze chezmoi template scripts using the Bash dialect.
- `"**/*zshrc" = "zsh"` and `"**/*zshenv" = "zsh"`: Instructs Shuck to analyze Zsh startup stubs and configurations using the native Zsh dialect, eliminating obsolete inline `# shellcheck shell=zsh` directives across all dotfiles.

### Directives Migration and ShellCheck Decommissioning

- **Directive Syntax**: Legacy `# shellcheck disable=...` directives were converted to native `# shuck: disable=...` directives across all shell scripts.
- **Purged Dead Codes**: Retired extension-specific codes (`SL1003`, `SL1005`, `SL2020`) from the uninstalled `shell-lsp` extension were permanently removed.
- **Template Delimiter Suppressions**: Added `C061` alongside `SC1083` in [`home/.chezmoiscripts/darwin/run_onchange_before_install-packages-darwin.sh.tmpl`](/home/.chezmoiscripts/darwin/run_onchange_before_install-packages-darwin.sh.tmpl) to prevent Shuck's parser from treating `{{- if ... }}` and `{{- end }}` blocks as stray command names.
- **Dynamic Sourcing Suppression**: Added `C003` in [`home/dot_zshenv`](/home/dot_zshenv) to suppress warnings where the sourced path is dynamically resolved via `$ZDOTDIR` at runtime.
- **Extended Glob Recursion Workaround**: Normalized pattern branches in `blame-ignore()` inside [`home/dot_config/zsh/dot_zshrc`](/home/dot_config/zsh/dot_zshrc) from empty group globs `style(|\(*\)):*)` to explicit alternates `style:* | style\(*\):*)`. This works around a recursion defect in Shuck's experimental formatter that repeatedly prepended `@` symbols on successive format runs.

### Vendor Script Protection

- Configured `exclude = ["**/*gemini/antigravity-cli/*.sh"]` under `[format]` in [`.shuck.toml`](/.shuck.toml).
- This exempts upstream Antigravity CLI title and statusline scripts from layout mutations, preserving exact line-for-line fidelity with upstream documentation while keeping them subject to static analysis via `shuck check`.

### Consequences

#### Good

- **Single Execution Engine**: One unified binary performs static analysis, layout formatting, and Language Server Protocol duties, replacing the editor-bound `shell-lsp` extension while avoiding the need to coordinate separate standalone tools (`shellcheck` and `shfmt`).
- **First-Class Zsh Support**: Zsh dotfiles are analyzed with native Zsh grammar awareness without generating false-positive dialect errors.
- **Zero Prettier Interference**: Configuring `"[shellscript]": { "editor.defaultFormatter": null }` in VS Code settings prevents Prettier from attempting to format shell files, while composite npm scripts format the entire repository in one pass.
- **Fast Pre-Commit Checks**: Rust-compiled native binary executes checks and formatting in under 20 milliseconds across staged files.
- **Clean Git History**: Formatting revisions were separated into a dedicated `style(shell)` commit (`33537e2`) and registered in [`.git-blame-ignore-revs`](/.git-blame-ignore-revs) to keep `git blame` annotations clean.

#### Bad

- **Experimental Formatter Flag**: Shuck requires `SHUCK_EXPERIMENTAL=1` to enable formatting capabilities (`shuck format`), reflecting ongoing development in its formatting engine.
- **Third-Party Tap Requirement**: Because `shuck-cli` is distributed via `ewhauser/tap` rather than Homebrew Core, initial machine provisioning requires executing `brew trust ewhauser/tap`.

#### Neutral

- **Directive Vendor Prefix**: Suppressions use the `# shuck:` prefix instead of `# shellcheck:`. Shuck maintains backward compatibility when reading legacy `SCxxxx` suppression codes.

### Confirmation

Compliance with this decision is enforced automatically across three layers:

1. **Local Pre-commit Hook**: Husky and `lint-staged` execute `env SHUCK_EXPERIMENTAL=1 shuck format` and `shuck check` on every commit affecting shell scripts.
2. **Repository Formatting Quality Gate**: `npm run format:check` runs Prettier check alongside `npm run format:shell:check` to ensure zero unformatted files exist.
3. **Repository Static Analysis Quality Gate**: `npm run lint:shell` runs `shuck check` across all tracked shell scripts, asserting exit code 0.

## Pros and Cons of the Options

### ewhauser/shuck (`shuck-cli`)

A unified Rust-based shell linter, formatter, and language server supporting POSIX sh, Bash, and Zsh.

- Good, because a single binary provides both static analysis and code formatting.
- Good, because native Zsh dialect support eliminates ShellCheck's `SC1071` dialect warnings.
- Good, because declarative configuration in [`.shuck.toml`](/.shuck.toml) centralizes per-file dialect mappings, tab indentation, and path exclusions.
- Good, because sub-20 ms execution keeps pre-commit hooks fast.
- Neutral, because it requires an explicit `[per-file-shell]` mapping for extensionless dotfiles and chezmoi templates.
- Bad, because `shuck format` requires the `SHUCK_EXPERIMENTAL=1` environment variable flag.
- Bad, because distribution relies on a third-party Homebrew tap (`ewhauser/tap`).

### Native System Binaries (`shellcheck` + `shfmt` via Homebrew)

Installing native Mach-O precompiled binaries for ShellCheck (Haskell) and shfmt (Go) through Homebrew Core.

- Good, because both tools are mature, industry-standard utilities maintained in Homebrew Core.
- Good, because native binaries execute with near-zero latency.
- Good, because both tools are pre-installed in default GitHub Actions runner environments.
- Neutral, because formatting settings can be partially read from [`.editorconfig`](/.editorconfig).
- Bad, because coordinating two independent tools requires maintaining separate invocation scripts and config files ([`.editorconfig`](/.editorconfig) and [`.shellcheckrc`](/.shellcheckrc)).
- Bad, because ShellCheck does not natively parse Zsh syntax, requiring `# shellcheck shell=...` annotations or skipping analysis entirely on Zsh dotfiles.
- Bad, because `shfmt` chokes on Zsh extended glob syntax (such as `style(|\(*\)):*)`) with fatal parse errors.

### Pure Node.js / WebAssembly Engine (`@wasm-fmt/shfmt` + `shellcheck-wasm`)

Compiling `shfmt` and `shellcheck` to WebAssembly bytecode and executing them inside the Node.js V8 runtime.

- Good, because dependencies are declared in `package.json` and install completely self-contained in `node_modules` without Homebrew.
- Good, because it operates identically across Linux, macOS, and Windows environments.
- Neutral, because custom file routing logic can be scripted directly in JavaScript.
- Bad, because neither package ships a turnkey CLI; adopting this requires writing and permanently maintaining a bespoke JavaScript runner script (`scripts/shell-tools.mjs`).
- Bad, because WASM compilation bridges are maintained by third-party individuals rather than primary upstream authors, posing long-term maintenance risks.
- Bad, because V8 startup and WASM bytecode instantiation add 150–300 ms of latency per invocation.

### Monolithic Editor Extension (`stubbedev.shell-lsp` in VS Code)

Relying on a VS Code extension to orchestrate formatting and linting via the Language Server Protocol.

- Good, because it required zero local CLI configuration beyond installing the extension from the VS Code Marketplace.
- Bad, because it provided no standalone CLI executable, preventing shell script validation in automated Git pre-commit hooks and CI pipelines.
- Bad, because diagnostics and formatting were coupled to the editor lifecycle, meaning files modified outside VS Code or via Git operations bypassed all linting and formatting gates.
- Bad, because formatting parse errors were silently swallowed and logged only to hidden output channels rather than surfacing in the editor's diagnostic panel.

## More Information

- [`Brewfile`](/Brewfile): Declares project-level Homebrew tap and formula dependencies.
- [`.shuck.toml`](/.shuck.toml): Canonical configuration file for dialect mappings, indentation, and exclusions.
- [`package.json`](/package.json): Task orchestration for `format:shell`, `format:shell:check`, `lint:shell`, and `lint-staged`.
- [`.git-blame-ignore-revs`](/.git-blame-ignore-revs): Records pure formatting commit hashes to ignore during Git blame analysis.
- [Shuck GitHub Repository](https://github.com/ewhauser/shuck): Upstream project documentation and issue tracking.
- [POSIX IEEE Std 1003.1 Shell Redirection Specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_07): Standard syntax specification for shell redirection operators.
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html): Conventions for redirection spacing and variable braces.

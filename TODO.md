# Zsh Tooling: Formatters & Linters Evaluation

## 📌 Executive Summary

A true "Prettier-for-Zsh" (in terms of natively parsing Zsh's highly permissive, context-dependent grammar) does not exist. Tools generally fall into two categories:

1. **POSIX-strict AST parsers** (like `shfmt` and `prettier-plugin-sh`) that require modifying your Zsh code to fit standard Bash syntax.
2. **Regex/Zsh-specific tools** (like `beautysh` or `zshellcheck`) that tolerate custom Zsh syntax but offer less intelligent spacing or lack VS Code extensions.

## 🧰 Formatters Comparison

| Feature                 | `prettier-plugin-sh`                  | `shfmt`                           | `beautysh`                               |
| :---------------------- | :------------------------------------ | :-------------------------------- | :--------------------------------------- |
| **Parsing Engine**      | AST-based (`mvdan-sh` / WASM)         | AST-based (Go - `mvdan-sh`)       | Regex-based (Python)                     |
| **Zsh Native Support**  | ❌ Poor (POSIX-strict)                | ❌ Poor (POSIX-strict)            | ⚠️ Partial (Regex-tolerant)              |
| **Formatting Style**    | Standardized Prettier (Single-space)  | Aggressive, strips custom spacing | Gentle, focuses on indentation           |
| **VS Code Integration** | Standard `Prettier` Extension         | `lumirelle.shell-format-rev`      | `mkhl.beautysh`                          |
| **Extra Capabilities**  | Formats Dockerfiles, .env, .gitignore | None                              | None                                     |
| **Best For**            | **Unified web-ecosystem workflows**   | Standalone CLI POSIX workflows    | Retaining Zsh syntax & visual alignments |

### Formatter Profiles

- **`prettier-plugin-sh` (by un-ts)**
  - **Mechanism:** A Prettier plugin that runs `sh-syntax` (a WASM port of `mvdan-sh`, which is the engine behind `shfmt`) under the hood.
  - **Pros:** Seamless integration into your existing Prettier workflow. If you already use Prettier for web development, this lets you format Zsh files using your standard `.prettierrc` configuration and the official Prettier VS Code extension. It also formats `.env`, `Dockerfile`, and `.gitignore` files.
  - **Cons:** **It does not solve the Zsh parsing problem.** Because it strictly wraps `mvdan-sh`'s default printer, it inherits all of `shfmt`'s limitations. It will fail on Zsh short loops, destroy tabular alignments, and heavily enforce POSIX strictness.

- **`shfmt` (via shell-format extension)**
  - **Mechanism:** Parses the script into a syntax tree via `mvdan-sh` in Go and reprints it.
  - **Pros:** Extremely fast and highly reliable for standard POSIX/Bash configurations.
  - **Cons:** Forces single-space arguments and destroys custom visual alignments. Chokes on Zsh-specific syntax (like the `for ... (...)` short loops).

- **`beautysh`**
  - **Mechanism:** Uses regular expressions to adjust indentation rather than building a syntax tree.
  - **Pros:** Leaves Zsh-specific syntax alone. Preserves inline spacing and custom tabular alignments.
  - **Cons:** Not a "true" formatter. It only handles indentation and can be easily confused by complex nested string manipulations or heredocs.

## 🔍 Linters Comparison

| Feature                 | `shellcheck`           | `zshellcheck`                   | `zsh-lint`                  |
| :---------------------- | :--------------------- | :------------------------------ | :-------------------------- |
| **Parsing Engine**      | AST-based (Haskell)    | AST-based (Go)                  | AST-based (Go)              |
| **Zsh Native Support**  | ❌ Poor (POSIX-strict) | ✅ Excellent (Zsh-specific)     | ✅ Excellent (Zsh-specific) |
| **Auto-fix Capability** | Yes (via flags)        | Yes (`-fix`)                    | No (Diagnostic only)        |
| **VS Code Extension**   | `timonwong.shellcheck` | ❌ None (CLI/CI only)           | ❌ None (CLI only)          |
| **CLI Availability**    | Yes                    | Yes                             | Yes                         |
| **Best For**            | Standard Bash / POSIX  | Zsh linting & modern auto-fixes | Deep semantic analysis      |

### Linter Profiles

- **`shellcheck`**
  - **Mechanism:** The industry standard for shell scripts.
  - **Pros:** Seamless VS Code integration, catches severe logic bugs, provides detailed wiki links for every error.
  - **Cons:** Fundamentally built for `sh`/`bash`. Will aggressively flag valid Zsh features as syntax errors.

- **`zshellcheck` (afadesigns/zshellcheck)**
  - **Mechanism:** A modern static analysis and auto-fix tool specifically designed for Zsh.
  - **Pros:** Features auto-fix capabilities for `setopts`, hooks, and globs. Integrates well with CI/CD and GitHub Actions pipelines.
  - **Cons:** Lacks a dedicated VS Code extension; primarily optimized for CLI, Git hooks, and CI/CD environments.

- **`zsh-lint` (z-shell/zsh-lint)**
  - **Mechanism:** A standalone semantic analyzer built in Go to parse Zsh scripts.
  - **Pros:** Reports greppable static-analysis diagnostics directly tailored to Zsh grammar.
  - **Cons:** No VS Code extension, lower adoption rate, and purely diagnostic (no auto-fix mechanism).

## ⚙️ Strategic Options for the Feature Branch

When you implement this feature branch later, you will need to choose one of these architectural paths based on your appetite for rewriting your Zsh syntax:

### Path A: The "Prettier Monolith" Workflow (Strict POSIX)

- **Tools:** `prettier` + `prettier-plugin-sh` + `shellcheck`
- **VS Code:** The official `Prettier - Code formatter` extension + `timonwong.shellcheck`
- **The Verdict:** If you are determined to have a unified web-ecosystem workflow, this is the best path. You can uninstall `lumirelle.shell-format-rev` entirely and let Prettier handle your dotfiles.
- **The Trade-off:** You still **must** write standard POSIX loops in your Zsh files (just like your recent fixes) because the Prettier plugin uses the exact same `mvdan-sh` parser under the hood.

### Path B: The "Zsh Native" Workflow (Regex & Specialized)

- **Tools:** `beautysh` (for indentation) + `zshellcheck` (for CI/CLI linting)
- **VS Code:** `mkhl.beautysh`
- **The Verdict:** The path to take if you absolutely refuse to give up Zsh syntactic sugar and manual tabular alignments.
- **The Trade-off:** You lose real-time, AST-powered auto-formatting and in-editor syntax error checking, relying instead on regex for indentation and manual CLI runs (or Git hooks) to catch logic errors.

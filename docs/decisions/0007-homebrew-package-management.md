---
status: "proposed"
date: 2026-10-03
---

# {short title, representative of solved problem and found solution}

## Context and Problem Statement

<!-- {Describe the context and problem statement, e.g., in free form using two to three sentences or in the form of an illustrative story. You may want to articulate the problem in form of a question. Consider adding links to collaboration boards or issue management systems. Make the scope of the decision explicit, for instance, by calling out or pointing at structural architecture elements (components, connectors, ...).} -->

<!-- Managing Homebrew packages via Chezmoi presents a fundamental architectural conflict between terminal flow (the speed of installing a package on the fly) and declarative synchronization (the necessity of updating dotfile source files).

The standard objective is to ensure that a machine's installed packages are fully represented in the dotfiles repository without introducing friction into the developer's daily workflow. -->

This is strictly parameterized, measurable comparison of all approaches to managing Homebrew via chezmoi using rigorous matrix (spreadsheet format) to evaluate technical trade-offs objectively.

| Parameter                                  | A1: chezmoi embedded                                                                        | A2: chezmoi standalone                                                                | A3: Custom imperative            | A4: Custom data-driven          |
| :----------------------------------------- | :------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------ | :------------------------------- | :------------------------------ |
| Origin                                     | [chezmoi](https://www.chezmoi.io/user-guide/machines/macos/#install-packages-with-a-script) | [chezmoi](https://www.chezmoi.io/user-guide/advanced/install-packages-declaratively/) | Custom                           | Custom                          |
| Workflow direction                         | Source&nbsp;→&nbsp;Target                                                                   | Source&nbsp;→&nbsp;Target                                                             | Target&nbsp;→&nbsp;Source        | Source&nbsp;→&nbsp;Target       |
| Package list syntax                        | Official (`Brewfile`)                                                                       | Official (`Brewfile`)                                                                 | Official (`Brewfile`)            | Custom (`.yaml` / `.json`)      |
| How `brew` reads dependencies during apply | Standard input (`/dev/stdin`)                                                               | Physical file                                                                         | Physical file                    | Individual `brew install` calls |
| Where the package list lives in source     | Embedded in the script                                                                      | Standalone `Brewfile.tmpl`                                                            | Machine-specific `Brewfile`s     | `.chezmoidata/` files           |
| Is the package list deployed locally?      | No                                                                                          | Yes (`~/.Brewfile`)                                                                   | Yes (`~/.config/homebrew/`)      | No                              |
| File topology (source)                     | Monolithic (1&nbsp;file)                                                                    | Monolithic (1&nbsp;file)                                                              | Machine-specific (2+&nbsp;files) | Monolithic (1&nbsp;file)        |
| Cross-machine logic                        | N/A (Not addressed)                                                                         | N/A (Not addressed)                                                                   | Folder segmentation              | YAML object nesting             |
| Add packages via CLI?                      | ❌                                                                                          | ❌                                                                                    | ✅                               | ❌                              |
| chezmoi script prefixes                    | `onchange_before_`                                                                          | `onchange_after_`                                                                     | `onchange_after_`                | `onchange_after_`               |
| chezmoi script execution trigger           | Script content changes                                                                      | Source template changes                                                               | Source `Brewfile` hash drifts    | Source data hash drifts         |
| How the package list is updated            | Manual                                                                                      | Manual                                                                                | Automatic (zsh function)         | Manual                          |
| `chezmoi status` alerting                  | ❌                                                                                          | ❌                                                                                    | ✅                               | ❌                              |
| `chezmoi re-add` safety                    | N/A                                                                                         | ❌ (Destroys `{{ if }}` logic)                                                        | ✅                               | N/A                             |
| Native `brew bundle cleanup`               | ❌ (No local file)                                                                          | ✅                                                                                    | ✅                               | ❌ (No local file)              |
| Status                                     | ❌ Discarded                                                                                | ❌ Discarded                                                                          | ✅ Accepted                      | ❌ Discarded                    |

## Decision Drivers

<!-- This is an optional element. Feel free to remove. -->

- {A desired software quality}
- {A faced concern}
- {A constraint or force}

## Considered Options

-

## Decision Outcome

Chosen option: "[Raw Split Target Files with Background Reconciliation](#raw-split-target-files-with-background-reconciliation)", because {justification. e.g., only option, which meets k.o. criterion decision driver | which resolves force {force} | … | comes out best (see below)}.

### Consequences

<!-- This is an optional element. Feel free to remove. -->

- Good, because {positive consequence, e.g., improvement of one or more desired qualities, …}
- Bad, because {negative consequence, e.g., compromising one or more desired qualities, …}

### Confirmation

<!-- This is an optional element. Feel free to remove. -->

{Describe how the implementation / compliance of the ADR can/will be confirmed. Is there any automated or manual fitness function? If so, list it and explain how it is applied. Is the chosen design and its implementation in line with the decision? E.g., a design/code review or a test with a library such as ArchUnit can help validate this. Note that although we classify this element as optional, it is included in many ADRs.}

## Pros and Cons of the Options

### 1

#### References

- [twpayne/chezmoi/assets/chezmoi.io/docs/user-guide/machines/macos.md][chezmoi-use-brew-bundle-to-manage-your-brews-and-casks]

#### Description

<details>
<summary>Use <code>brew bundle</code> to manage your brews and casks</summary>

Homebrew's [`brew bundle` subcommand][brew-bundle] allows you to specify a list of brews and casks to be installed. You can integrate this with chezmoi by creating a `run_onchange_` script. For example, create a file in your source directory called `run_onchange_before_install-packages-darwin.sh.tmpl` containing:

```txt
{{- if eq .chezmoi.os "darwin" -}}
#!/bin/bash

brew bundle --file=/dev/stdin <<EOF
brew "git"
cask "google-chrome"
EOF
{{ end -}}
```

The `Brewfile` is embedded directly in the script with a bash here document. chezmoi will run this script whenever its contents change, i.e. when you add or remove brews or casks.
</details>

#### Pros

Keeps all package logic strictly within the Chezmoi source directory.

#### Cons

Violates the "destination -> source" workflow. To install a package, the user must open the dotfiles repository, manually add the line, and run `chezmoi apply`. This interrupts standard terminal flow (`brew install <pkg>`).

### 2

#### References

- [twpayne/chezmoi/assets/chezmoi.io/docs/user-guide/advanced/install-packages-declaratively.md][chezmoi-install-packages-declaratively]

#### Description

<details>
<summary>Install packages declaratively</summary>

chezmoi uses a declarative approach for the contents of dotfiles, but package installation requires running imperative commands. However, you can simulate declarative package installation with a combination of a `.chezmoidata` file and a `run_onchange_` script.

The following example uses [homebrew][brew] on macOS, but should be adaptable to other operating systems and package managers.

First, create `.chezmoidata/packages.yaml` declaring the packages that you want installed, for example:

```yaml
packages:
  darwin:
    brews:
      - "git"
    casks:
      - "google-chrome"
```

Second, create a `run_onchange_darwin-install-packages.sh.tmpl` script that uses the package manager to install those packages, for example:

```txt
{{ if eq .chezmoi.os "darwin" -}}
#!/bin/bash

brew bundle --file=/dev/stdin <<EOF
{{ range .packages.darwin.brews -}}
brew {{ . | quote }}
{{ end -}}
{{ range .packages.darwin.casks -}}
cask {{ . | quote }}
{{ end -}}
EOF
{{ end -}}
```

Now, when you run `chezmoi apply`, chezmoi will execute the `install-packages.sh` script when the list of packages defined in `.chezmoidata/packages.yaml` changes.
</details>

#### Pros

#### Cons

### 3

#### References

- [twpayne/chezmoi/assets/chezmoi.io/docs/user-guide/use-scripts-to-perform-actions.md][chezmoi-use-scripts-to-perform-actions]

#### Description

<details>
<summary>Install packages with scripts</summary>

Change to the source directory and create a file called `run_onchange_install-packages.sh`. In this file create your package installation script, e.g.

```sh
#!/bin/sh
sudo apt install ripgrep
```

The next time you run [`chezmoi apply`][apply] or [`chezmoi update`][update] this script will be run. As it has the `run_onchange_` prefix, it will not be run again unless its contents change, for example if you add more packages to be installed.

This script can also be a template. For example, if you create `run_onchange_install-packages.sh.tmpl` with the contents:

```text
{{ if eq .chezmoi.os "linux" -}}
#!/bin/sh
sudo apt install ripgrep
{{ else if eq .chezmoi.os "darwin" -}}
#!/bin/sh
brew install ripgrep
{{ end -}}
```

This will install `ripgrep` on both Debian/Ubuntu Linux systems and macOS.
</details>

<details>
<summary>Run a script when the contents of another file changes</summary>

chezmoi's `run_` scripts are run every time you run [`chezmoi apply`][apply], whereas `run_onchange_` scripts are run only when their contents have changed, after executing them as templates. You can use this to cause a `run_onchange_` script to run when the contents of another file has changed by including a checksum of the other file's contents in the script.

For example, if your [dconf][dconf] settings are stored in `dconf.ini` in your source directory then you can make `chezmoi apply` only load them when the contents of `dconf.ini` has changed by adding the following script as `run_onchange_dconf-load.sh.tmpl`:

```title="~/.local/share/chezmoi/run_onchange_dconf-load.sh.tmpl"
#!/bin/bash

# dconf.ini hash: {{ include "dconf.ini" | sha256sum }}
dconf load / < {{ joinPath .chezmoi.sourceDir "dconf.ini" | quote }}
```

As the SHA256 sum of `dconf.ini` is included in a comment in the script, the contents of the script will change whenever the contents of `dconf.ini` are changed, so chezmoi will re-run the script whenever the contents of `dconf.ini` change.

In this example you should also add `dconf.ini` to [`.chezmoiignore`][ignore] so chezmoi does not create `dconf.ini` in your home directory.
</details>

#### Pros

#### Cons

### Current implementation

#### Description

The previous state of the `main` branch utilized a Bash script parsing separated template lists within a heredoc.

#### Pros

Allowed machine-specific package isolation.

#### Cons

Inherited the same terminal flow interruption as the official recommendation. Furthermore, syntax highlighting and Homebrew API descriptions were lost because the packages were embedded inside a `.sh.tmpl` file.

### Interactive Zsh Wrapper

#### Description

We experimented with a Zsh wrapper that intercepted `brew install` and prompted the user via the terminal (`[c]ommon, [p]ersonal, [w]ork`) to categorize the package immediately.

#### Pros

Maintained machine-specific separation while utilizing native `brew bundle add` to update target `.Brewfile`s directly on the machine.

#### Cons

The interactive prompt blocked the terminal, breaking automated scripts and adding cognitive load during standard development tasks.

### Template Orchestration

#### Description

We attempted to consolidate packages into a single `~/.config/homebrew/Brewfile` target by concatenating `.chezmoitemplates` components (`common.Brewfile` + `personal.Brewfile`). The Zsh wrapper would blindly append (`brew bundle add`) new packages to this single target file.

#### Pros

No interactive prompt; invisible background execution.

#### Cons

`brew bundle add` natively alphabetizes and groups (tap, brew, cask, mas) the entire target file. When `chezmoi diff` compared the native globally-sorted file against the linearly-concatenated Chezmoi template, the resulting diff was unreadable, showing massive line reordering. This proved that Chezmoi templates and native Homebrew commands cannot concurrently manage the layout of the same file.

### Raw Split Target Files with Background Reconciliation

#### Description

1. **Raw Source Files:** The dotfiles repository maintains three independent source files: `common.Brewfile`, `personal.Brewfile`, and `work.Brewfile`. They are synced directly to `~/.config/homebrew/` without template concatenation.
2. **Target Isolation:** `~/.config/homebrew/` will contain `common.Brewfile` alongside exactly one specific file (`personal.Brewfile` OR `work.Brewfile`), controlled by Chezmoi's `.chezmoiignore` negations.
3. **Background Wrapper:** The `brew`, `mas`, and `npm` Zsh aliases execute the native install command, return the prompt instantly, and fork a background job. The background job blindly executes `brew bundle add <pkg> --file=~/.config/homebrew/<specific>.Brewfile`, defaulting all un-categorized installations to the machine-specific file.
4. **Sweeping Uninstalls:** The wrapper intercepts `uninstall` commands and iterates through all available `.Brewfile`s on the machine, silently executing `brew bundle remove` to ensure the package is dropped from whichever file it resides in.

#### Pros

- **Uninterrupted Terminal Flow:** The user executes `brew install <pkg>` normally without interactive prompts.
- **Native Formatting:** Because `brew bundle add` targets raw, independent files, Homebrew automatically alphabetizes the packages and injects API descriptions natively without triggering template conflicts in Chezmoi.
- **Asynchronous Reconciliation:** The default routing to the machine-specific file acts as a local buffer. The user can periodically run `chezmoi status`, review a clean `chezmoi diff`, and either run `chezmoi re-add` (if the package is machine-specific) or manually cut-and-paste the declaration to `common.Brewfile` before re-adding.

#### Cons

- **Temporary Misclassification:** A package that globally belongs in `common.Brewfile` will temporarily live in the machine-specific file until the user manually reconciles it during the next `chezmoi status` review.
- **MAS App Auto-healing:** `brew bundle add` does not support Mac App Store apps. The wrapper must manually append (`echo`) them to the bottom of the file. However, Homebrew automatically re-sorts the entire file upon the execution of the next standard `brew bundle add`, making this self-healing.

## More Information

<!-- This is an optional element. Feel free to remove. -->

{You might want to provide additional evidence/confidence for the decision outcome here and/or document the team agreement on the decision and/or define when/how this decision the decision should be realized and if/when it should be re-visited. Links to other decisions and resources might appear here as well.}

[brew]: https://brew.sh
[brew-bundle]: https://docs.brew.sh/Manpage#bundle-subcommand
[chezmoi-install-packages-declaratively]: https://github.com/twpayne/chezmoi/blob/master/assets/chezmoi.io/docs/user-guide/advanced/install-packages-declaratively.md?plain=1
[chezmoi-use-brew-bundle-to-manage-your-brews-and-casks]: https://github.com/twpayne/chezmoi/blob/master/assets/chezmoi.io/docs/user-guide/machines/macos.md?plain=1
[chezmoi-use-scripts-to-perform-actions]: https://github.com/twpayne/chezmoi/blob/master/assets/chezmoi.io/docs/user-guide/use-scripts-to-perform-actions.md?plain=1

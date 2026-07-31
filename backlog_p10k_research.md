# Backlog: Powerlevel10k Research

## Directory Styling (`POWERLEVEL9K_DIR_CLASSES`)

Research the `POWERLEVEL9K_DIR_CLASSES` styling feature in Powerlevel10k to understand how directories are styled based on their path, writability, and existence.

### Context Snippet

```zsh
  # For example, given these settings:
  #
  #   typeset -g POWERLEVEL9K_DIR_CLASSES=(
  #     '~/work(|/*)'  WORK     ''
  #     '~(|/*)'       HOME     ''
  #     '*'            DEFAULT  '')
  #
  # Whenever the current directory is ~/work or a subdirectory of ~/work, it gets styled with one
  # of the following classes depending on its writability and existence: WORK, WORK_NOT_WRITABLE or
  # WORK_NON_EXISTENT.
```

### Reference Links

- Zsh4Humans README: https://raw.githubusercontent.com/romkatv/zsh4humans/refs/heads/master/README.md
- Powerlevel10k README (Transient Prompt / Config): https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/README.md

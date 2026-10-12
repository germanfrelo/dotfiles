# Should `dot_zshrc` become a template?

The only real need comes from the `homebrew/<machine_type>/Brewfile`. Only that one value depends on the machine.

What templating the whole 360-line file costs:

- `chezmoi re-add` won't overwrite templates (chezmoi `re-add` reference, as of my training data). Quick edits to `~/.config/zsh/.zshrc` could no longer be pulled back automatically.
- VS Code needs the `*zshrc*` file association to highlight `dot_zshrc.tmpl`. That's exactly the change your staged revert is undoing here.

What I'd do instead:

- Create a tiny template, e.g. `home/private_dot_config/zsh/machine.zsh.tmpl`, holding only the machine-dependent exports, such as `HOMEBREW_BUNDLE_FILE` with `{{ .machine_type }}`.
- Load it from `.zshrc` with `z4h source`. The zsh4humans template allows this: settings belong "in this file or in files sourced from it", and it shows `z4h source ~/.env.zsh` as the example.
- The big file stays plain, so `re-add` keeps working.
- There's a bonus: `brew bundle add`, `check` and `cleanup` all read `HOMEBREW_BUNDLE_FILE`, so the drift check and your manual `brew bundle add <pkg>` habit no longer need `--file`. I'm confident this variable exists in the Homebrew manpage's environment section, but check it against your installed version.

The other option is to template the whole file, which only makes sense if you expect many more personal/work differences.

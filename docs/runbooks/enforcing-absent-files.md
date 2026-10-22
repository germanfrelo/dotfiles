# Enforcing Absent Files

Operational guide for enforcing or reverting absent dotfiles in this repository using chezmoi `remove_` source attributes.

## Overview

Some files must be permanently absent from the system to prevent configuration conflicts or unwanted tool behavior (for example, preventing `~/.editorconfig` from breaking Prettier JSONC parsing, or preventing `.zprofile` from duplicating zsh4humans environment setup).

Chezmoi supports this natively through the `remove_` attribute prefix.
When a file prefixed with `remove_` exists in the source state, chezmoi deletes the target file from the destination directory whenever `chezmoi apply` runs.

## Core Invariants

1. **Mandatory Decision Record**: Every enforced-absent file must be justified by an Architectural Decision Record in [`docs/decisions/`](/docs/decisions/).
2. **Internal Decision Link**: The `remove_` source file must contain a comment linking to its decision record.
3. **Chezmoiignore Un-ignore**: If the target path resides inside a broadly ignored directory (e.g. `.config/**/*`), every intermediate directory in its path (e.g. `!.config/zsh/`) and the target file itself must be explicitly un-ignored using a negation (`!`) in [`home/.chezmoiignore`](/home/.chezmoiignore). Otherwise, chezmoi skips the directory tree entirely and never executes the removal.
4. **Automated Tracking**: The pre-commit hook automatically scans for `remove_` files and updates the `## Enforced absent` section in [`MANAGED.txt`](/MANAGED.txt). Never edit [`MANAGED.txt`](/MANAGED.txt) manually.

## Procedure: Enforcing a New Absent File

### Step 1: Author the Architectural Decision Record

1. Create a new decision record in `docs/decisions/NNNN-<slug>.md` using the project's standard ADR template.
2. Clearly document the problem, the conflict caused by the file's presence, the evaluated alternatives, and the decision to enforce its absence.

### Step 2: Create the `remove_` Source File

1. Translate the target destination path into a chezmoi source path, prefixing the file basename with `remove_`:
   - `~/.file` -> `home/remove_dot_file`
   - `~/.config/app/file` -> `home/dot_config/app/remove_file`
   - `~/.config/app/.file` -> `home/dot_config/app/remove_dot_file`

2. Add a comment linking to the ADR as the file's content:

   ```text
   # This file instructs chezmoi to delete `~/.path/to/target` if it exists.
   # Decision: /docs/decisions/NNNN-<slug>.md
   ```

### Step 3: Update `home/.chezmoiignore` (if Applicable)

1. Inspect [`home/.chezmoiignore`](/home/.chezmoiignore) to determine if the target path is matched by a broad ignore pattern (such as `.config/**/*`).

2. If ignored, un-ignore every intermediate directory first (if not already un-ignored), then un-ignore the target file with a descriptive comment:

   ```text
   !.config/app/
   !.config/app/target # Required to allow chezmoi to see and execute the 'remove_' operation
   ```

### Step 4: Preview and Apply Changes

1. Preview the deletion operation using dry-run:

   ```sh
   chezmoi apply --dry-run --verbose <target-path>
   ```

   Confirm that chezmoi reports the target as scheduled for deletion (`rm <target-path>`).

2. Execute the removal:

   ```sh
   chezmoi apply --verbose <target-path>
   ```

3. Verify that the file has been removed from the filesystem.

### Step 5: Stage and Commit

1. Stage the new ADR, the `remove_` source file, and `.chezmoiignore` (if modified):

   ```sh
   git add docs/decisions/NNNN-<slug>.md home/<path>/remove_<name> [home/.chezmoiignore]
   ```

2. The pre-commit hook automatically runs `node scripts/managed.js > MANAGED.txt`, staging the updated `## Enforced absent` list.

3. Commit using conventional commit format:

   ```sh
   git commit -m "feat(<tool>): Enforce absence of <file>"
   ```

## Procedure: Reverting an Enforced Absent File

To restore or re-enable a previously absent file:

1. **Supersede Decision Record**: Update the ADR status in `docs/decisions/NNNN-<slug>.md` to `superseded`, citing the new decision record.

2. **Remove Source File**: Delete the source `remove_` file using `trash`:

   ```sh
   trash home/<path>/remove_<name>
   ```

3. **Clean Up `.chezmoiignore`**: Remove the negation (`!`) line for the file from [`home/.chezmoiignore`](/home/.chezmoiignore). If no other managed files remain in that directory, remove the intermediate directory negation as well.

4. **Re-manage Target (Optional)**: If the file is now actively managed, create or add the destination file (`chezmoi add <target-path>`).

5. **Verify and Apply**: Preview and apply the reversion, scoped to the target path:

   ```sh
   chezmoi apply --dry-run --verbose <target-path>
   chezmoi apply --verbose <target-path>
   ```

6. **Commit Changes**: Stage the changes and commit:

   ```sh
   git add docs/decisions/NNNN-<slug>.md home/<path>/remove_<name> [home/.chezmoiignore]
   git commit -m "revert(<tool>): Stop enforcing absence of <file>"
   ```

   The pre-commit hook will automatically update and stage the removal from [`MANAGED.txt`](/MANAGED.txt).

## Current Enforced Absent Files Inventory

| Target Path               | Source Path                                                                           | Decision Record                                                          | Chezmoiignore Negation                                                               |
| :------------------------ | :------------------------------------------------------------------------------------ | :----------------------------------------------------------------------- | :----------------------------------------------------------------------------------- |
| `~/.editorconfig`         | [`home/remove_dot_editorconfig`](/home/remove_dot_editorconfig)                       | [ADR 0003](/docs/decisions/0003-enforce-absence-of-home-editorconfig.md) | None (root file)                                                                     |
| `~/.zprofile`             | [`home/remove_dot_zprofile`](/home/remove_dot_zprofile)                               | [ADR 0001](/docs/decisions/0001-enforce-absence-of-zprofile.md)          | None (root file)                                                                     |
| `~/.config/zsh/.zprofile` | [`home/dot_config/zsh/remove_dot_zprofile`](/home/dot_config/zsh/remove_dot_zprofile) | [ADR 0001](/docs/decisions/0001-enforce-absence-of-zprofile.md)          | Required (`!.config/zsh/.zprofile` in [`home/.chezmoiignore`](/home/.chezmoiignore)) |

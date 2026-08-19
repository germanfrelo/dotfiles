# feat(macos): Disable window drop shadows in screenshots

## Motivation & Context

By default, macOS captures a massive drop shadow when taking a screenshot of a specific window. This extra padding creates unnecessary whitespace, increases file sizes slightly, and leads to visual inconsistency when pasting UI elements into documentation, notes, or web applications.

This change configures the macOS defaults to strip the shadow, resulting in clean, tightly cropped window captures.

## Changes Proposed

- Updates the macOS configuration script to disable shadows in the Apple screencapture domain.
- Appends the UI server restart command to ensure the change takes effect immediately upon running the bootstrap/setup script, without requiring a system reboot.

## Implementation

To apply the configuration:

```sh
defaults write com.apple.screencapture disable-shadow -bool true
```

To reload the UI server so the change takes effect:

```sh
killall SystemUIServer
```

## Rollback / Teardown

If this behavior needs to be reverted to the factory default, the preference key should be deleted entirely rather than hard-coding a boolean. This keeps the configuration file clean.

To restore shadows:

```sh
defaults delete com.apple.screencapture disable-shadow
killall SystemUIServer
```

## Verification Steps

1. Run the updated dotfiles setup script.
2. Trigger a window screenshot (CMD + SHIFT + 4, then press Spacebar).
3. Click on any active window.
4. Verify the resulting image file is tightly cropped to the window borders with no shadow padding.

## References & Notes

- **Apple Official Documentation:** The `-bool` flag explicitly sets the correct Boolean data type in the property list file, as defined in the macOS manual page for the defaults command.
- **MacPaw Article:** Many online guides, such as [this MacPaw article](https://macpaw.com/how-to/remove-mac-screenshot-shadow), omit the `-bool` flag. **Warning:** While macOS type-coercion currently allows the MacPaw command to work by falling back to a string, omitting the flag is technically incorrect and writes the wrong data type. Using the explicit `-bool` flag is the strictly correct, future-proof approach for dotfiles.

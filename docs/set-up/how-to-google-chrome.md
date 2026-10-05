# How to set up Google Chrome

- [Disable media key control in Google Chrome](https://www.omgchrome.com/chrome-google-music-media-keys/) → Enter `chrome://flags/#hardware-media-key-handling` in Chrome and change it to `Disabled`.

is there a way to save sync a google chrome flag in the account

No, you cannot sync Google Chrome flags (chrome://flags) to your Google account.
Chrome flags are stored locally on each device per user profile, meaning they will not automatically transfer or synchronize when you log into your Google account on another computer or device.

## How to Manually Track and Apply Flags

If you want to use the same flags across multiple devices or after resetting your device, you can back them up manually:

1.  Open Google Chrome and type chrome://version into the address bar.
2.  Look for the line labeled --feature-flags=.
3.  Copy all the text located inside the square brackets [...].
4.  Paste that text into a plain text file and save it in a secure place like Google Drive.
5.  On your new or reset device, you will still need to manually re-enable each individual flag or use command-line switches to re-apply them.

If you want, I can share a quick guide on how to launch Chrome with command-line flags using your saved text file.

[https://support.google.com](https://support.google.com/chromebook/thread/234002886/how-to-save-restore-flag-enable?hl=en)

This?<tr><td class="label">Command Line</td> <td class="version" id="command_line"> /Applications/Google Chrome.app/Contents/MacOS/Google Chrome --flag-switches-begin --disable-features=HardwareMediaKeyHandling --flag-switches-end --origin-trial-disabled-features=CanvasTextNg|WebAssemblyCustomDescriptors</td> </tr>

Yes, that is exactly where Chrome lists them! The code snippet you found under chrome://version shows the absolute raw command line Chrome used to launch its current session.
However, you cannot copy and paste that line exactly as it is to launch Chrome on a new machine. It contains internal "bookkeeping" wrappers that have no effect when run manually. [2, 3]

## Breaking Down Your Snippet

-
- The Executable Path: /Applications/Google Chrome.app/Contents/MacOS/Google Chrome (This is the actual path to the Chrome app on a Mac).
- The Bookkeeping Wrappers: --flag-switches-begin, --flag-switches-end, and --origin-trial-disabled-features=.... Chrome adds these automatically to keep track of what you changed inside chrome://flags, but they do nothing if you type them into a terminal manually.
- The Actual Flag: --disable-features=HardwareMediaKeyHandling. This is the actual hidden feature change you made. [2, 3, 4, 5, 6, 7, 8]
-

## How to use this to launch Chrome on a Mac

If you want to manually launch Chrome on a Mac using the flag from your snippet, open your Terminal app and run the following cleaned-up command (ensuring you escape the space in the app name with a backslash \):

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --disable-features=HardwareMediaKeyHandling

(Note: Always make sure you completely quit Chrome by using Cmd + Q before running this command, otherwise it will just open a normal window without applying the flag). [6, 9]
Would you like to know how to save this clean command as a clickable desktop shortcut or script so you don't have to type it into the Terminal every time?

[https://www.reddit.com](https://www.reddit.com/r/chromeos/comments/r8xsv5/any_way_to_save_chrome_flag_profile/)
[https://gist.github.com](https://gist.github.com/dodying/34ea4760a699b47825a766051f47d43b)
[https://thorium.rocks](https://thorium.rocks/docs/cmdline_flags.html)
[https://issues.chromium.org](https://issues.chromium.org/564522509)
[5] [https://stackoverflow.com](https://stackoverflow.com/questions/13146125/how-can-i-launch-chrome-with-flags-from-command-line-more-concisely)
[https://www.chromium.org](https://www.chromium.org/developers/how-tos/run-chromium-with-flags/)
[https://support.google.com](https://support.google.com/chrome/thread/264881586/hardware-media-key-handling-no-longer-available-in-chrome-flags-lists?hl=en)
[https://www.reddit.com](https://www.reddit.com/r/chrome/comments/1bjunvh/how_do_i_redisable_volume_media_player_media_key/)
[https://github.com](https://github.com/sinch/start-chrome-with-flags)

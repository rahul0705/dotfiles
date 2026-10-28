# Screenshot preferences

Part of [#101](https://github.com/rahul0705/dotfiles/issues/101) and the
[#81](https://github.com/rahul0705/dotfiles/issues/81) Etch dogfood effort.

## Inspection and desired state

On October 28, 2026, `defaults read` and `defaults export` found the three
candidate keys unset. The user chose PNG, window shadows enabled, and an
unmanaged destination to preserve macOS behavior without a machine-specific path.

| Domain | Key | Plist type | Inspected value | Desired state |
| --- | --- | --- | --- | --- |
| `com.apple.screencapture` | `type` | String | Unset | `png` |
| `com.apple.screencapture` | `disable-shadow` | Boolean | Unset | `false` (shadows enabled) |
| `com.apple.screencapture` | `location` | String if configured | Unset | Unmanaged |

An unset key means no explicit saved value; it does not establish every effective
Screenshot app setting. The module does not set or delete `location`, create a
screenshot directory, or embed an absolute home path. Existing destination
customizations on other machines are preserved. The current defaults provider
writes strings literally, so a `~` path should not be assumed to expand inside
a preference value.

## Apply and refresh

The macOS-only `screenshots` module is included in the developer profile and
can be applied independently:

```sh
./etch plan screenshots
./etch apply screenshots
./etch apply screenshots  # matching keys should be skipped
```

Etch's native `macos_defaults` provider writes only the two declared keys; it
does not replace the plist. No sudo is required. Linux and Windows skip the
whole module.

The module does not restart SystemUIServer or other UI processes. After applying,
close and reopen the Screenshot controls with Shift-Command-5, then take a test
window screenshot to confirm PNG output, shadows, and the save destination.
Apple documents the [Screenshot controls and capture options](https://support.apple.com/102646).
If the settings still appear stale, a manual `killall SystemUIServer` is an
optional troubleshooting step; it briefly restarts system UI. No process restart
is built into apply or repeat apply.

## Verification evidence

Live verification on October 28, 2026:

- Initial plan reported `type` and `disable-shadow` missing.
- First apply wrote String `png` and Boolean `false` respectively.
- Exported values and types matched both declarations.
- Every undeclared preference remained equal before and after apply; `location`
  stayed unset.
- A second apply skipped the action; a subsequent plan reported one skip.
- Linux and Windows OS simulations skipped the module before provider inspection.

No screenshots were captured and no UI processes were restarted during agent
verification. Actual image format, window-shadow appearance, save destination,
and whether a process refresh is needed remain for the manual capture check.

# Dock and Mission Control preferences

Part of [#99](https://github.com/rahul0705/dotfiles/issues/99) and the
[#81](https://github.com/rahul0705/dotfiles/issues/81) Etch dogfood effort.

## Inspection and desired state

On October 28, 2026, `defaults read` and `defaults export` inspected these
preferences on the current Mac before choosing desired state. The user selected
auto-hide on, icon size 59, automatic Spaces rearrangement off, and recent
applications on. Preserve the observed floating-point type for icon size.

| Domain | Key | Plist type | Inspected value | Desired value |
| --- | --- | --- | --- | --- |
| `com.apple.dock` | `autohide` | Boolean | `true` | `true` |
| `com.apple.dock` | `tilesize` | Real | `59.0` | `59.0` |
| `com.apple.dock` | `mru-spaces` | Boolean | `false` | `false` |
| `com.apple.dock` | `show-recents` | Boolean | Unset | `true` |

`mru-spaces` controls Mission Control's automatic rearrangement of Spaces based
on recent use. `show-recents` keeps recent applications visible rather than
hiding them. An unset saved key does not, by itself, establish the effective UI
value. This module explicitly records the selected preference.

Dock application membership and ordering are not managed. The module does not
write `persistent-apps`, `persistent-others`, or any complete plist file.

## Apply and refresh

The macOS-only `dock` module is included in the developer profile and can also
be selected independently:

```sh
./etch plan dock
./etch apply dock
./etch apply dock  # matching keys should be skipped
```

Etch's registered `macos_defaults` provider reconciles only the four declared
keys through the preferences system. No sudo is needed, and unrelated
preferences remain untouched. Linux and Windows skip the entire module.

The module does not restart Dock or `cfprefsd`. If Dock has not picked up a
change, finish Dock interactions and restart it manually when convenient:

```sh
killall Dock
```

Dock normally relaunches automatically; this briefly interrupts its UI.

## Verification evidence

Live verification on October 28, 2026:

- Initial plan reported only `show-recents` missing; the other three keys matched.
- First apply changed only `show-recents` to Boolean `true`.
- Exported plist values and types matched all four declarations.
- Every undeclared preference remained equal before and after apply, including
  Dock application membership/order.
- A second apply skipped the action; a subsequent plan reported one skip.

No automatic Dock restart occurred. Live visual behavior after a refresh was
not independently checked; plist reconciliation and idempotence were verified.

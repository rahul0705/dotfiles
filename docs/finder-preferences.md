# Finder preferences

Part of [#98](https://github.com/rahul0705/dotfiles/issues/98) and the
[#81](https://github.com/rahul0705/dotfiles/issues/81) Etch dogfood effort.

## Inspection and desired state

On October 9, 2026, `defaults read` and `defaults export` on the current Mac
found all six keys unset. Unset means no explicit saved preference; it does
not prove a particular effective value in Finder. These are the proposed
portable defaults, rather than a copy of implicit macOS defaults.

| Domain | Key | Type | Inspected value | Desired value |
| --- | --- | --- | --- | --- |
| `NSGlobalDomain` | `AppleShowAllExtensions` | Boolean | Unset | `true` |
| `com.apple.finder` | `ShowPathbar` | Boolean | Unset | `true` |
| `com.apple.finder` | `ShowStatusBar` | Boolean | Unset | `true` |
| `com.apple.finder` | `AppleShowAllFiles` | Boolean | Unset | `false` |
| `com.apple.desktopservices` | `DSDontWriteNetworkStores` | Boolean | Unset | `true` |
| `com.apple.desktopservices` | `DSDontWriteUSBStores` | Boolean | Unset | `true` |

Extensions and the path/status bars make file names and navigation explicit.
Hidden files stay hidden by default; use Finder's Command-Shift-period toggle
when needed. Preventing new `.DS_Store` files on network and removable volumes
avoids carrying Finder metadata onto shared/external storage. Existing
`.DS_Store` files are not deleted. Local-volume behavior remains unmanaged.

## Apply and refresh

The macOS-only `finder` module is in the developer profile. Preview and apply
it independently:

```sh
./etch plan finder
./etch apply finder
./etch apply finder  # matching keys should be skipped
```

The registered Etch `macos_defaults` plugin writes only declared keys through
the preferences system; it preserves unrelated preferences and does not replace
plist files. No sudo is required. `NSGlobalDomain` affects other apps too.

If Finder has not picked up a change, finish file operations and relaunch it
manually: hold Option, right-click Finder in the Dock, then choose Relaunch.
The module does not restart Finder or `cfprefsd` automatically. See
[Apple's preferences guidance](https://support.apple.com/guide/terminal/edit-property-lists-apda49a1bb2-577e-4721-8f25-ffc0836f6997/mac).

## Verification evidence

A disposable preferences domain was tested with the pinned native provider:
plan named the missing keys; apply wrote all six values as booleans; an unrelated
string key remained intact; a second apply skipped the action. The test domain
was deleted afterwards. This checks reconciliation without changing live Finder
preferences. Live Finder behavior, including network/removable-volume metadata,
still needs confirmation after the user applies the module.

# Global macOS preferences

Part of [#102](https://github.com/rahul0705/dotfiles/issues/102) and the
[#81](https://github.com/rahul0705/dotfiles/issues/81) Etch dogfood effort.

## Audit and scope

On October 28, 2026, `defaults export NSGlobalDomain -` inspected a focused set
of appearance, scrollbar, tabbing, save, print, and document-restoration settings.
The user selected automatic appearance switching only. Unset means no explicit
saved value; it does not prove a particular effective value in every app.

All keys below are in `NSGlobalDomain`:

| Candidate key | Observed value/type | Default or unmanaged behavior | Decision |
| --- | --- | --- | --- |
| `AppleInterfaceStyleSwitchesAutomatically` | `true`, Boolean | Auto is an explicit appearance choice; do not assume an unset key enables it | Manage `true` |
| `AppleInterfaceStyle` | Unset | macOS controls the current Light/Dark appearance | Leave unmanaged; do not pin the instantaneous theme |
| `AppleShowScrollBars` | Unset | System Settings can select device-dependent, scrolling-only, or always-visible scrollbars | Leave unmanaged |
| `AppleWindowTabbingMode` | Unset | Supported apps use the system's window-tabbing preference | Leave unmanaged |
| `NSDocumentSaveNewDocumentsToCloud` | Unset | Save behavior remains app/account dependent | Leave unmanaged |
| `NSNavPanelExpandedStateForSaveMode` | Unset | Keep existing save-panel behavior | Leave unmanaged |
| `NSNavPanelExpandedStateForSaveMode2` | Unset | Keep existing save-panel behavior | Leave unmanaged |
| `PMPrintingExpandedStateForPrint` | Unset | Keep existing print-panel behavior | Leave unmanaged |
| `PMPrintingExpandedStateForPrint2` | Unset | Keep existing print-panel behavior | Leave unmanaged |
| `NSQuitAlwaysKeepsWindows` | Unset | Keep existing document/window restoration behavior | Leave unmanaged |
| `NSCloseAlwaysConfirmsChanges` | Unset | Keep existing document-close behavior | Leave unmanaged |

No plist value type was observed for unset candidates, and factory values for
those private keys were not independently established. They are not copied from
online tweak lists or configured speculatively. Locale, language, hardware, and
machine-specific values are outside this portable preference selection.

Filename-extension visibility remains owned by `finder`, even though its key
also lives in `NSGlobalDomain`. Keyboard/text-input candidates such as automatic
capitalization, spelling correction, smart quotes, dash/period substitution, and
repeat behavior belong in [#100](https://github.com/rahul0705/dotfiles/issues/100).
Dock/Mission Control and screenshot settings remain in their respective modules.

## Managed setting and rationale

The macOS-only `macos-global` module declares:

- Domain: `NSGlobalDomain`.
- Key: `AppleInterfaceStyleSwitchesAutomatically`.
- Plist type: Boolean.
- Desired value: `true`, matching the observed personal preference.

This preserves automatic Light/Dark appearance as part of the portable
environment without fixing the current appearance to one mode. Apple documents
that [Auto follows the configured Night Shift schedule](https://support.apple.com/guide/mac-help/mchl52e1c2d2/mac).
The schedule itself, location/time-zone settings, and app-specific themes remain
unmanaged. The module is deliberately not a miscellaneous preferences bucket.

## Apply and refresh

The module is included in the developer profile:

```sh
./etch plan macos-global
./etch apply macos-global
./etch apply macos-global  # matching values should be skipped
```

Etch's native `macos_defaults` provider reconciles only the declared key and
preserves unrelated global preferences. No sudo, complete-plist replacement,
forced theme transition, notification script, logout, or process restart occurs.
Linux and Windows skip the entire module.

For a manual behavior check, open System Settings > Appearance and confirm Auto.
Apps may follow changes immediately or require reopening. A newly configured
machine may need a new login session if its running appearance services have not
reloaded the preference. This was not needed or tested on the inspected Mac,
whose saved setting already matched. No automatic refresh is built into apply.

## Verification evidence

On October 28, 2026:

- Inventory preceded selection and configuration.
- Live plan and both applies skipped the matching Boolean; no live settings changed.
- In a unique disposable preferences domain, the same declared key was initially
  absent. Apply wrote Boolean `true`, preserved an unrelated string, and a second
  apply skipped the action. The disposable domain was deleted afterwards.
- Linux/Windows OS simulations skipped the module before provider inspection.

The live Light/Dark schedule transition and appearance UI were not independently
observed. This evidence covers typed reconciliation, preservation, and idempotence.

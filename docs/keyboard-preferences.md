# Keyboard and text-input preferences

Part of [#100](https://github.com/rahul0705/dotfiles/issues/100) and the
[#81](https://github.com/rahul0705/dotfiles/issues/81) Etch dogfood effort.

## Inspection and selected state

On October 28, 2026, `defaults export NSGlobalDomain -` inspected the current
keyboard/input preferences before selecting desired state. The user chose to
preserve all five enabled text helpers and leave timing and press-and-hold
behavior unmanaged.

All keys below are in `NSGlobalDomain`:

| Key | Observed value/type | Desired state | Behavior |
| --- | --- | --- | --- |
| `NSAutomaticCapitalizationEnabled` | `true`, Boolean | `true` | Automatic capitalization |
| `NSAutomaticSpellingCorrectionEnabled` | `true`, Boolean | `true` | Automatic spelling correction |
| `NSAutomaticQuoteSubstitutionEnabled` | `true`, Boolean | `true` | Smart quotation marks |
| `NSAutomaticDashSubstitutionEnabled` | `true`, Boolean | `true` | Smart dash substitution |
| `NSAutomaticPeriodSubstitutionEnabled` | `true`, Boolean | `true` | Period insertion after a double space |
| `KeyRepeat` | Unset; no type observed | Unmanaged | Repeat speed |
| `InitialKeyRepeat` | Unset; no type observed | Unmanaged | Initial repeat delay |
| `ApplePressAndHoldEnabled` | Unset; no type observed | Unmanaged | Accent-menu versus repeated-character behavior in supporting apps |

Unset means no explicit saved value, not a measured effective timing or a
particular behavior in every app. No numeric repeat values or private supported
ranges are assumed. To adjust those settings, use the supported Keyboard sliders
for [repeat rate and delay](https://support.apple.com/guide/mac-help/mchl0311bdb4/mac).
The module neither sets nor deletes those keys, including custom values on
other machines.

These are intentional portable text-entry preferences matching the inspected
Mac, rather than a blanket set of coding-oriented overrides. Apps can override
or ignore the global helpers. Code-editor behavior and per-app substitution
settings remain app-owned. Apple describes the supported
[text and punctuation substitutions](https://support.apple.com/guide/mac-help/mh35735/mac).

Hardware mappings, keyboard layouts, input sources, language/quote-style choices,
app-specific shortcuts, and app-specific spelling settings remain out of scope.
Appearance stays in `macos-global`; Finder, Dock, and screenshot settings remain
in their subsystem modules even where they share a global preference domain.

## Apply and refresh

The macOS-only `keyboard` module is included in the developer profile:

```sh
./etch plan keyboard
./etch apply keyboard
./etch apply keyboard  # matching values should be skipped
```

Etch's native `macos_defaults` provider writes only the five declared Boolean
keys. It preserves unrelated preferences and does not replace the global plist.
Linux and Windows skip the whole module. No sudo, forced app restart, logout,
or UI process restart is part of apply.

To check actual typing behavior, reopen a supporting text-entry app and test
capitalization, spelling, quotes, dashes, and double-space period insertion in a
new disposable document. Check the app's own substitution settings if it differs.
Apps may cache global preferences until reopened; a new login session is another
manual refresh option if needed. Neither was required or tested on the inspected
Mac, whose saved values already matched.

## Verification evidence

On October 28, 2026:

- The eight candidate keys were inspected before configuration.
- Live plan and both applies skipped the five matching Booleans; no live typing
  preferences changed. The three unmanaged keys stayed unset.
- In a unique disposable domain, apply wrote all five initially missing Booleans
  as `true`, preserved preexisting repeat/hold settings and an unrelated string,
  and skipped the second apply. The disposable domain was deleted afterwards.
- Linux/Windows OS simulations skipped the module before provider inspection.

This verifies typed reconciliation, preservation, and idempotence. Actual typing
behavior in individual apps and any refresh requirement remain for manual checks.

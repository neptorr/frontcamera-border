# Changelog

## v0.6.4

- Increase the protection circle radius by 3 px (41 px to 44 px), keeping its center at (540, 60).
- Keep the Overlay Manager output-capture fix and one-time SystemUI reload after overlay setup.

## v0.6.3

- Increase the protection circle radius by 2 px (39 px to 41 px), keeping its center at (540, 60).
- Keep the Overlay Manager output-capture fix and one-time SystemUI reload after overlay setup.

## v0.6.2

- Increase the protection circle radius by 1 px (38 px to 39 px), keeping its center at (540, 60).
- Capture Overlay Manager command output instead of redirecting it directly to the service log; direct file redirection caused fabricated-overlay transactions to fail on the tested ROM.
- Restart SystemUI once after applying overlays so the camera-protection listener reloads the configured path.
- Keep the native SystemUI camera callback and headless module behavior.

## v0.5.8

- Added the cutout-path bounds adjustment for the tested Galaxy A52s ROM.
- Delegated camera open/close behavior to native SystemUI callbacks; removed polling and overlay toggles.
- Added module metadata and uninstall cleanup; author is neptorr.
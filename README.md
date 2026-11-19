# Front Camera Border

A root module for the **Samsung Galaxy A52s 5G** that enables Android's native SystemUI camera protection ring around the front camera cutout.

## Latest version

**v0.5.8** — fixes the cutout protection view being clipped at the bottom on the tested A52s ROM. The ring is centered around the camera hole and follows SystemUI's native camera activity callback.

- No companion app; nothing appears in the app drawer.
- No camera polling or periodic enable/disable loop.
- Uses fabricated Android Runtime Resource Overlays (RROs).
- Module author: **neptorr**.

## Compatibility

- Device: Samsung Galaxy A52s 5G (SM-A528B / a52sxq)
- Root manager: Magisk or compatible root module installer
- Display: 1080 × 2400, tested configuration
- Camera ID: `1` (front camera on the tested build)
- ROM must include SystemUI camera protection support.

Other ROMs or camera ID mappings may differ. This module applies a SystemUI cutout configuration and a framework cutout-fill setting; it does not replace camera software or change camera selection.

## Install

1. Download `CameraRing-A52s-Native-v0.5.8.zip` from the v0.5.8 release.
2. In Magisk, open **Modules → Install from storage** and select the ZIP.
3. Reboot the phone.
4. Open any app using the front camera to check the ring.

The module is headless and should not show an app icon in the launcher.

## Remove

Uninstall the module in Magisk and reboot. Its uninstall script disables only the fabricated overlays created by this module and the superseded ring-path overlay.

## Source

- [Module source](module/)
- [Changelog](CHANGELOG.md)

## License

MIT. See [LICENSE](LICENSE).

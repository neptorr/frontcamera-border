# Front Camera Border

A headless root module for the Samsung Galaxy A52s 5G that uses Android's native SystemUI camera-protection ring around the front-camera cutout.

## Latest version

**v0.6.4** increases the protection circle radius to 44 px. It also fixes overlay setup on the tested ReSukiSu/KernelSU ROM and restarts SystemUI once so its camera-protection listener reloads the configured path.

- No companion app or launcher icon.
- No camera polling or periodic overlay toggling. SystemUI handles camera availability.
- Uses fabricated Android Runtime Resource Overlays (RROs).
- The one-time SystemUI restart causes a brief status-bar/SystemUI refresh.


## Compatibility

- Device: Samsung Galaxy A52s 5G (SM-A528B / a52sxq)
- Root manager: ReSukiSu/KernelSU, Magisk, or a compatible module installer
- Tested display configuration: 1080 × 2400
- Front camera ID: `1` on the tested ROM
- ROM must include SystemUI camera-protection support.

Other ROMs or camera-ID mappings may differ. This module configures SystemUI's native camera-protection path and Android's cutout-fill setting; it does not replace camera software or change camera selection.

## Install

1. Download [CameraRing-A52s-Native-v0.6.4.zip](CameraRing-A52s-Native-v0.6.4.zip).
2. Install it as an update in ReSukiSu/KernelSU or your compatible root module manager.
3. Reboot the phone.
4. Open an app using the front camera and check the ring.

## Remove

Uninstall the module in the root manager and reboot. Its uninstall script disables only this module's fabricated overlays and the superseded ring-path overlay.

## Source

- [Module source](module/)
- [Changelog](CHANGELOG.md)

## License

MIT. See [LICENSE](LICENSE).

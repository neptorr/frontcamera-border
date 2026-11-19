# Front Camera Border

A lightweight Magisk module for the **Samsung Galaxy A52s 5G** that displays a subtle black ring around the front-camera cutout only while the front camera is active.

## Features

- Uses Android's native fabricated Runtime Resource Overlays (RRO).
- Automatically detects front-camera activity.
- Shows the cutout ring while the front camera is in use and hides it when the camera closes.
- Starts automatically after boot through Magisk.
- No companion APK required.

## Compatibility

- Device: Samsung Galaxy A52s 5G
- Root: Magisk
- Display resolution: 1080 × 2400
- Front camera ID tested: `1`

Camera IDs can vary by device firmware. The included configuration targets the tested front camera ID.

## Installation

1. Download the latest Magisk ZIP from the repository.
2. Open Magisk and choose **Modules → Install from storage**.
3. Select the ZIP and reboot.
4. Open the front camera to test the ring.

## Uninstallation

Remove the module from Magisk and reboot.

## How it works

The module creates native Android fabricated overlays for the display cutout and monitors active camera clients. It enables the overlays when the tested front camera is active and disables them when it is no longer active.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

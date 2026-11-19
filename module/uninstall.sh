#!/system/bin/sh
# Disable only this module's fabricated overlays, plus the superseded path overlay.
for name in A52sNativeRingEnable A52sNativeRingCameraId A52sNativeRingPath A52sNativeRingPathBounds A52sNativeCutoutFill; do
    /system/bin/cmd overlay disable "com.android.shell:$name" >/dev/null 2>&1
done

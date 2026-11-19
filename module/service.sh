#!/system/bin/sh
# Static configuration only. SystemUI itself handles camera open/close callbacks.

STATE_DIR=/data/adb/camera-ring-native
LOG="$STATE_DIR/service.log"
TARGET=com.android.systemui
OWNER=com.android.shell

mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"
log() { echo "$(date '+%F %T') $*" >> "$LOG"; }

# Wait until Android's overlay service and SystemUI are ready.
until [ "$(/system/bin/getprop sys.boot_completed)" = "1" ]; do sleep 2; done
sleep 8

if ! /system/bin/pm path "$TARGET" >/dev/null 2>&1; then
    log "ERROR: SystemUI package not found; no overlays created."
    exit 0
fi

ensure_overlay() {
    name="$1"
    resource="$2"
    type="$3"
    value="$4"
    id="$OWNER:$name"

    status="$(/system/bin/cmd overlay list 2>/dev/null | /system/bin/grep -F "$id")"
    if [ -z "$status" ]; then
        /system/bin/cmd overlay fabricate --target-name SystemUI --target "$TARGET" --name "$name" \
            "$resource" "$type" "$value" >> "$LOG" 2>&1
        rc=$?
        if [ "$rc" -ne 0 ]; then
            log "ERROR: fabricate failed for $name (exit $rc)."
            return 1
        fi
        status="$(/system/bin/cmd overlay list 2>/dev/null | /system/bin/grep -F "$id")"
    fi

    case "$status" in
        *"[x]"*)
            log "$id is already enabled."
            return 0
            ;;
    esac

    /system/bin/cmd overlay enable "$id" >> "$LOG" 2>&1
    rc=$?
    if [ "$rc" -ne 0 ]; then
        status="$(/system/bin/cmd overlay list 2>/dev/null | /system/bin/grep -F "$id")"
        case "$status" in
            *"[x]"*) log "Enable returned $rc, but $id is active." ;;
            *) log "ERROR: enable failed for $id (exit $rc)."; return 1 ;;
        esac
    fi
    log "Applied $id to $TARGET."
    return 0
}

ensure_framework_cutout_fill() {
    name=A52sNativeCutoutFill
    id="$OWNER:$name"
    status="$(/system/bin/cmd overlay list android 2>/dev/null | /system/bin/grep -F "$id")"
    if [ -z "$status" ]; then
        /system/bin/cmd overlay fabricate --target-name FrameworkConfig --target android --name "$name" \
            android:bool/config_fillMainBuiltInDisplayCutout 0x12 1 >> "$LOG" 2>&1
        rc=$?
        if [ "$rc" -ne 0 ]; then
            log "ERROR: framework cutout-fill overlay failed (exit $rc)."
            return 1
        fi
        status="$(/system/bin/cmd overlay list android 2>/dev/null | /system/bin/grep -F "$id")"
    fi
    case "$status" in
        *"[x]"*)
            log "$id is already enabled."
            return 0
            ;;
    esac
    /system/bin/cmd overlay enable "$id" >> "$LOG" 2>&1
    rc=$?
    if [ "$rc" -ne 0 ]; then
        status="$(/system/bin/cmd overlay list android 2>/dev/null | /system/bin/grep -F "$id")"
        case "$status" in
            *"[x]"*) log "Enable returned $rc, but $id is active." ;;
            *) log "ERROR: framework cutout-fill enable failed (exit $rc)."; return 1 ;;
        esac
    fi
    log "Enabled framework cutout fill so ScreenDecorations can create its cutout view."
    return 0
}

log "Camera Ring Native v0.5.8 service started; bottom-clip bounds fix; static resources only."
ensure_overlay A52sNativeRingEnable \
    com.android.systemui:bool/config_enableDisplayCutoutProtection 0x12 1 || exit 0
ensure_overlay A52sNativeRingCameraId \
    com.android.systemui:string/config_protectedCameraId string 1 || exit 0
# This 1x1 triangle sits inside the already-black top-left rounded corner. It extends the
# path bounds to y=0, allowing ScreenDecorations to measure the full absolute y=22..98 circle.
# The camera ring itself remains centered at (540,60), radius 38px.
/system/bin/cmd overlay disable "${OWNER}:A52sNativeRingPath" >/dev/null 2>&1
ensure_overlay A52sNativeRingPathBounds \
    com.android.systemui:string/config_frontBuiltInDisplayCutoutProtection string \
    "M 0,0 L 1,0 L 0,1 Z M 540,22 a 38,38 0 1,0 0,76 a 38,38 0 1,0 0,-76 Z" || exit 0
ensure_framework_cutout_fill || exit 0
sleep 3
/system/bin/cmd overlay list android 2>/dev/null | /system/bin/grep -F A52sNativeCutoutFill >> "$LOG"
/system/bin/cmd overlay list "$TARGET" 2>/dev/null | /system/bin/grep -F A52sNativeRing >> "$LOG"
log "Configuration applied. Camera open/close behavior is delegated to SystemUI; no polling or camera-state overlay toggles."

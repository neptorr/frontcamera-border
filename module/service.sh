#!/system/bin/sh
# Static configuration only. SystemUI itself handles camera open/close callbacks.

STATE_DIR=/data/adb/camera-ring-native
LOG="$STATE_DIR/service.log"
TARGET=com.android.systemui
OWNER=com.android.shell

mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"
log() { echo "$(date '+%F %T') $*" >> "$LOG"; }

# Run framework shell commands without inherited module-manager libraries or stdin.
run_overlay() {
    LD_LIBRARY_PATH= LD_PRELOAD= PATH=/system/bin:/system/xbin /system/bin/cmd overlay "$@" </dev/null
}

until [ "$(/system/bin/getprop sys.boot_completed)" = "1" ]; do sleep 2; done

# KernelSU/ROM startup can report boot complete before OverlayManager accepts calls.
wait_for_overlay_service() {
    attempt=1
    while [ "$attempt" -le 12 ]; do
        output="$(run_overlay list android 2>&1)"
        rc=$?
        if [ "$rc" -eq 0 ] && echo "$output" | /system/bin/grep -x "android" >/dev/null 2>&1; then
            log "Overlay Manager service is ready."
            return 0
        fi
        log "Overlay Manager not ready (attempt $attempt/12, exit $rc); retrying."
        sleep 5
        attempt=$((attempt + 1))
    done
    log "ERROR: Overlay Manager did not become ready; no overlays changed."
    return 1
}

ensure_overlay() {
    target="$1"
    target_name="$2"
    name="$3"
    resource="$4"
    type="$5"
    value="$6"
    id="$OWNER:$name"

    attempt=1
    while [ "$attempt" -le 6 ]; do
        status="$(run_overlay list "$target" 2>/dev/null | /system/bin/grep -F "$id")"
        if [ -z "$status" ]; then
            # Do not redirect cmd output to a file: on this ROM that makes
            # OverlayManager's fabricate transaction fail. Capture it through
            # a pipe instead, then write diagnostics via the logger.
            command_output="$(run_overlay fabricate --target-name "$target_name" --target "$target" --name "$name" "$resource" "$type" "$value" 2>&1)"
            rc=$?
            if [ -n "$command_output" ]; then
                log "fabricate output for $id: $command_output"
            fi
            status="$(run_overlay list "$target" 2>/dev/null | /system/bin/grep -F "$id")"
            if [ -z "$status" ]; then
                log "Overlay $id not available after create attempt $attempt/6 (exit $rc); retrying in 5s."
                sleep 5
                attempt=$((attempt + 1))
                continue
            fi
        fi
        break
    done

    if [ -z "$status" ]; then
        log "ERROR: could not create or find $id."
        return 1
    fi
    case "$status" in
        *"[x]"*)
            log "$id is already enabled."
            return 0
            ;;
    esac

    attempt=1
    while [ "$attempt" -le 6 ]; do
        command_output="$(run_overlay enable "$id" 2>&1)"
        rc=$?
        if [ -n "$command_output" ]; then
            log "enable output for $id: $command_output"
        fi
        status="$(run_overlay list "$target" 2>/dev/null | /system/bin/grep -F "$id")"
        case "$status" in
            *"[x]"*)
                log "Enabled $id."
                return 0
                ;;
        esac
        log "Overlay $id still disabled after enable attempt $attempt/6 (exit $rc); retrying."
        sleep 2
        attempt=$((attempt + 1))
    done

    log "ERROR: failed to enable $id."
    return 1
}

log "Camera Ring Native v0.6.2 service started; applies the 1px thicker path and reloads SystemUI after configuration."
wait_for_overlay_service || exit 0
ensure_overlay "$TARGET" SystemUI A52sNativeRingEnable com.android.systemui:bool/config_enableDisplayCutoutProtection 0x12 1 || exit 0
ensure_overlay "$TARGET" SystemUI A52sNativeRingCameraId com.android.systemui:string/config_protectedCameraId string 1 || exit 0
# The 1x1 triangle anchors the path bounds at y=0. The ring remains centered at (540,60), r=44px.
# This lets SystemUI size the cutout decoration view to include the entire lower arc.
ensure_overlay "$TARGET" SystemUI A52sNativeRingPathBounds com.android.systemui:string/config_frontBuiltInDisplayCutoutProtection string "M 0,0 L 1,0 L 0,1 Z M 540,16 a 44,44 0 1,0 0,88 a 44,44 0 1,0 0,-88 Z" || exit 0
disable_output="$(run_overlay disable "$OWNER:A52sNativeRingPath" 2>&1)"
if [ -n "$disable_output" ]; then
    log "disable output for legacy path: $disable_output"
fi
ensure_overlay android FrameworkConfig A52sNativeCutoutFill android:bool/config_fillMainBuiltInDisplayCutout 0x12 1 || exit 0

log "Configuration applied. Camera open/close behavior is delegated to SystemUI; no polling or camera-state overlay toggles."

# CameraAvailabilityListener reads and caches its protection Path at creation.
# Restart SystemUI once so it reads the newly fabricated overlay resources.
log "Restarting SystemUI to reload the camera protection path."
restart_output="$(/system/bin/killall com.android.systemui 2>&1)"
restart_rc=$?
if [ -n "$restart_output" ]; then
    log "SystemUI restart output: $restart_output"
fi
sleep 3
if /system/bin/pidof com.android.systemui >/dev/null 2>&1; then
    log "SystemUI process is running after restart request."
else
    log "WARNING: SystemUI process is not visible after restart request (killall exit $restart_rc)."
fi

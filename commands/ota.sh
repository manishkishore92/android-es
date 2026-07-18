#!/usr/bin/env bash
cmd_ota() {
  local action="${1:-metadata}"
  shift || true
  case "$action" in
    metadata)
      local zip_file url out checksum size timestamp filename
      zip_file="${1:-}"
      if [[ -z "$zip_file" ]]; then
        zip_file="$(latest_file "$ANDROID_ROOT/out/target/product/${DEVICE_CODENAME:-}" '*.zip')"
      fi
      [[ -n "$zip_file" && -f "$zip_file" ]] || die "ROM zip not found. Usage: ./android-es ota metadata <zip-file> [download-url]"
      url="${2:-}"
      checksum="$(sha256sum "$zip_file" | awk '{print $1}')"
      size="$(stat -c%s "$zip_file")"
      timestamp="$(date +%s)"
      filename="$(basename "$zip_file")"
      ensure_dir "$(project_root)/ota"
      out="$(project_root)/ota/${DEVICE_CODENAME:-device}-ota.json"
      cat > "$out" <<JSON
{
  "datetime": $timestamp,
  "filename": "$filename",
  "id": "$checksum",
  "romtype": "${ROM_TYPE:-UNOFFICIAL}",
  "size": $size,
  "url": "$url",
  "device": "${DEVICE_CODENAME:-}",
  "branch": "${ROM_BRANCH:-}"
}
JSON
      success "OTA metadata created: $out"
      ;;
    *)
      die "Unknown OTA action: $action"
      ;;
  esac
}

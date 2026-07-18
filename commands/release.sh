#!/usr/bin/env bash
find_rom_zip() {
  if [[ -n "${1:-}" ]]; then
    printf "%s\n" "$1"
    return 0
  fi
  local dir="$ANDROID_ROOT/out/target/product/${DEVICE_CODENAME:-}"
  latest_file "$dir" '*.zip'
}

cmd_release() {
  local action="${1:-create}"
  shift || true
  case "$action" in
    create)
      local zip_file release_root release_dir checksum size now notes info_json flash_file
      zip_file="$(find_rom_zip "${1:-}")"
      [[ -n "$zip_file" && -f "$zip_file" ]] || die "ROM zip not found. Pass a zip path or configure DEVICE_CODENAME."
      now="$(date +%Y%m%d-%H%M%S)"
      release_root="$(project_root)/releases"
      release_dir="$release_root/${DEVICE_CODENAME:-device}-$now"
      ensure_dir "$release_dir"
      checksum="$(sha256sum "$zip_file" | awk '{print $1}')"
      size="$(stat -c%s "$zip_file")"
      notes="$release_dir/release-notes.md"
      info_json="$release_dir/build-info.json"
      flash_file="$release_dir/flash-instructions.md"

      cp "$zip_file" "$release_dir/$(basename "$zip_file")"
      printf "%s  %s\n" "$checksum" "$(basename "$zip_file")" > "$release_dir/checksums.txt"

      cat > "$notes" <<NOTES
# Release Notes

## Build

| Field | Value |
| --- | --- |
| ROM | $ROM_NAME |
| Device | ${DEVICE_CODENAME:-Not set} |
| Brand | ${DEVICE_BRAND:-Not set} |
| Branch | ${ROM_BRANCH:-Not set} |
| Maintainer | ${MAINTAINER_NAME:-Not set} |
| File | $(basename "$zip_file") |
| Size | $(human_bytes "$size") |
| SHA256 | $checksum |
| Date | $(date -u '+%Y-%m-%d %H:%M:%S UTC') |

## Notes

- Confirm the device codename before flashing.
- Back up important data before clean flashing.
- Use matching firmware for the selected branch and device tree.
- Review recovery, encryption, and firmware requirements before sharing publicly.

## Verification

Run:

\`\`\`bash
sha256sum $(basename "$zip_file")
\`\`\`

The output should match the checksum listed above.
NOTES

      cat > "$info_json" <<JSON
{
  "rom": "$ROM_NAME",
  "device": "${DEVICE_CODENAME:-}",
  "brand": "${DEVICE_BRAND:-}",
  "branch": "${ROM_BRANCH:-}",
  "maintainer": "${MAINTAINER_NAME:-}",
  "file": "$(basename "$zip_file")",
  "size_bytes": $size,
  "sha256": "$checksum",
  "generated_at_utc": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
}
JSON

      cat > "$flash_file" <<FLASH
# Flash Instructions

1. Confirm that the target device codename is \`${DEVICE_CODENAME:-device}\`.
2. Charge the device and back up important data.
3. Use the recommended recovery for this ROM source.
4. Clean flash when moving from another ROM or encrypted setup.
5. Flash firmware if the device tree requires a specific firmware base.
6. Flash the ROM zip.
7. Reboot and wait for the first boot to finish.

Always review device-specific notes before sharing public builds.
FLASH

      success "Release package created: $release_dir"
      ;;
    *)
      die "Unknown release action: $action"
      ;;
  esac
}

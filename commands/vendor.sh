#!/usr/bin/env bash
cmd_vendor() {
  local action="${1:-inspect}"
  case "$action" in
    inspect)
      local vendor device_tree prop_file missing=0 checked=0
      vendor="$(resolve_vendor_tree)"
      device_tree="$(resolve_device_tree)"
      [[ -n "$vendor" ]] || die "Vendor tree path is not configured"
      section "Vendor Tree Inspection"
      printf "Path: %s\n" "$vendor"
      [[ -d "$vendor" ]] || die "Vendor tree not found: $vendor"

      check_file "$vendor/Android.mk" "Android.mk" || true
      check_file "$vendor/Android.bp" "Android.bp" || true
      check_file "$vendor/${DEVICE_CODENAME:-device}-vendor.mk" "device vendor makefile" || true
      check_dir "$vendor/proprietary" "proprietary blobs" || true
      check_dir "$vendor/firmware" "firmware" || true
      check_dir "$vendor/etc" "etc" || true
      check_dir "$vendor/overlay" "vendor overlay" || true

      section "Blob Reference Check"
      prop_file="$device_tree/proprietary-files.txt"
      if [[ -f "$prop_file" ]]; then
        while IFS= read -r line; do
          line="${line%%#*}"
          line="${line%%|*}"
          line="${line%%;*}"
          line="${line##-}"
          [[ -z "$line" ]] && continue
          checked=$((checked + 1))
          if [[ ! -e "$vendor/proprietary/$line" && ! -e "$vendor/$line" ]]; then
            printf "Missing: %s\n" "$line"
            missing=$((missing + 1))
          fi
        done < "$prop_file"
        if [[ "$missing" -eq 0 ]]; then
          success "All checked blob references exist ($checked entries)"
        else
          warn "$missing missing blob references found from $checked checked entries"
        fi
      else
        warn "proprietary-files.txt not found in device tree"
      fi

      section "Vendor Files"
      find "$vendor" -maxdepth 2 -type f \( -name '*.mk' -o -name '*.bp' -o -name '*.xml' \) -print | sort
      ;;
    *)
      die "Unknown vendor action: $action"
      ;;
  esac
}

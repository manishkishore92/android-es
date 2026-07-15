#!/usr/bin/env bash
cmd_device() {
  local action="${1:-inspect}"
  case "$action" in
    inspect)
      local tree
      tree="$(resolve_device_tree)"
      [[ -n "$tree" ]] || die "Device tree path is not configured"
      section "Device Tree Inspection"
      printf "Path: %s\n" "$tree"
      [[ -d "$tree" ]] || die "Device tree not found: $tree"

      check_file "$tree/AndroidProducts.mk" "AndroidProducts.mk" || true
      check_file "$tree/BoardConfig.mk" "BoardConfig.mk" || true
      check_file "$tree/device.mk" "device.mk" || true
      check_file "$tree/vendorsetup.sh" "vendorsetup.sh" || true
      check_file "$tree/extract-files.sh" "extract-files.sh" || true
      check_file "$tree/proprietary-files.txt" "proprietary-files.txt" || true
      check_dir "$tree/rootdir" "rootdir" || true
      check_dir "$tree/sepolicy" "sepolicy" || true
      check_dir "$tree/overlay" "overlay" || true
      check_dir "$tree/init" "init" || true
      check_dir "$tree/recovery" "recovery" || true

      section "Detected Signals"
      grep -R "AB_OTA_UPDATER\|AB_OTA_PARTITIONS" "$tree" >/dev/null 2>&1 && success "A/B update configuration detected" || warn "A/B update configuration not detected"
      grep -R "PRODUCT_USE_DYNAMIC_PARTITIONS\|BOARD_SUPER_PARTITION" "$tree" >/dev/null 2>&1 && success "Dynamic partition configuration detected" || warn "Dynamic partition configuration not detected"
      grep -R "PRODUCT_SHIPPING_API_LEVEL" "$tree" >/dev/null 2>&1 && success "Shipping API level found" || warn "Shipping API level not found"
      grep -R "TARGET_KERNEL_SOURCE\|TARGET_KERNEL_CONFIG" "$tree" >/dev/null 2>&1 && success "Kernel references found" || warn "Kernel references not found"
      grep -R "DEVICE_MANIFEST_FILE\|manifest.xml" "$tree" >/dev/null 2>&1 && success "VINTF manifest reference found" || warn "VINTF manifest reference not found"

      section "Makefile Summary"
      find "$tree" -maxdepth 2 \( -name '*.mk' -o -name '*.bp' \) -print | sort
      ;;
    *)
      die "Unknown device action: $action"
      ;;
  esac
}

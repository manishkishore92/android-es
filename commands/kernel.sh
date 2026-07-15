#!/usr/bin/env bash
cmd_kernel() {
  local action="${1:-inspect}"
  case "$action" in
    inspect)
      local tree
      tree="$(resolve_kernel_tree)"
      [[ -n "$tree" ]] || die "Kernel tree path is not configured"
      section "Kernel Inspection"
      printf "Path: %s\n" "$tree"
      [[ -d "$tree" ]] || die "Kernel tree not found: $tree"
      check_file "$tree/Makefile" "Kernel Makefile" || true
      [[ -n "$KERNEL_DEFCONFIG" ]] && check_file "$tree/arch/$KERNEL_ARCH/configs/$KERNEL_DEFCONFIG" "Defconfig: $KERNEL_DEFCONFIG" || warn "KERNEL_DEFCONFIG not configured"
      [[ -d "$tree/drivers" ]] && success "drivers directory found" || warn "drivers directory missing"
      [[ -d "$tree/arch/$KERNEL_ARCH" ]] && success "arch/$KERNEL_ARCH found" || warn "arch/$KERNEL_ARCH missing"
      [[ -f "$tree/arch/$KERNEL_ARCH/boot/Image.gz" ]] && success "Image.gz already exists" || true
      [[ -f "$tree/arch/$KERNEL_ARCH/boot/Image.gz-dtb" ]] && success "Image.gz-dtb already exists" || true
      [[ -f "$tree/arch/$KERNEL_ARCH/boot/dts/dtbo.img" ]] && success "dtbo.img already exists" || true
      has_cmd clang && success "Clang available" || warn "Clang not found"
      has_cmd make && success "Make available" || warn "Make not found"
      ;;
    build)
      local tree log_dir log_file
      tree="$(resolve_kernel_tree)"
      [[ -d "$tree" ]] || die "Kernel tree not found: $tree"
      [[ -n "$KERNEL_DEFCONFIG" ]] || die "KERNEL_DEFCONFIG is not configured"
      log_dir="$(project_root)/logs"
      ensure_dir "$log_dir"
      log_file="$log_dir/kernel-${DEVICE_CODENAME:-device}-$(date +%Y%m%d-%H%M%S).log"
      cd "$tree"
      info "Building kernel"
      info "Log: $log_file"
      make O="$KERNEL_OUT" ARCH="$KERNEL_ARCH" SUBARCH="$KERNEL_SUBARCH" "$KERNEL_DEFCONFIG" 2>&1 | tee "$log_file"
      make O="$KERNEL_OUT" ARCH="$KERNEL_ARCH" SUBARCH="$KERNEL_SUBARCH" -j"$JOBS" 2>&1 | tee -a "$log_file"
      success "Kernel build finished"
      ;;
    package)
      local tree any image out_dir package_dir
      tree="$(resolve_kernel_tree)"
      any="$ANYKERNEL_DIR"
      [[ -d "$tree" ]] || die "Kernel tree not found: $tree"
      [[ -d "$any" ]] || die "AnyKernel3 directory not found. Set ANYKERNEL_DIR in config."
      image="$tree/$KERNEL_OUT/arch/$KERNEL_ARCH/boot/Image.gz-dtb"
      [[ -f "$image" ]] || image="$tree/$KERNEL_OUT/arch/$KERNEL_ARCH/boot/Image.gz"
      [[ -f "$image" ]] || die "Kernel image not found in output directory"
      out_dir="$(project_root)/kernel-packages"
      ensure_dir "$out_dir"
      package_dir="$out_dir/${DEVICE_CODENAME:-device}-kernel-$(date +%Y%m%d-%H%M%S)"
      cp -a "$any" "$package_dir"
      cp "$image" "$package_dir/"
      (cd "$package_dir" && zip -qr "../$(basename "$package_dir").zip" .)
      success "Kernel package created: $out_dir/$(basename "$package_dir").zip"
      ;;
    *)
      die "Unknown kernel action: $action"
      ;;
  esac
}

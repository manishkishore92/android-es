#!/usr/bin/env bash
cmd_doctor() {
  section "Required Tools"
  local failures=0
  check_cmd git "sudo apt install git" || failures=$((failures + 1))
  check_cmd repo "mkdir -p ~/.bin && curl https://storage.googleapis.com/git-repo-downloads/repo -o ~/.bin/repo && chmod +x ~/.bin/repo" || failures=$((failures + 1))
  check_cmd python3 "sudo apt install python3" || failures=$((failures + 1))
  check_cmd java "sudo apt install openjdk-17-jdk" || failures=$((failures + 1))
  check_cmd adb "sudo apt install android-tools-adb" || failures=$((failures + 1))
  check_cmd fastboot "sudo apt install android-tools-fastboot" || failures=$((failures + 1))
  check_cmd ccache "sudo apt install ccache" || true
  check_cmd make "sudo apt install make" || failures=$((failures + 1))
  check_cmd gcc "sudo apt install gcc" || true
  check_cmd clang "sudo apt install clang" || true

  section "Java"
  if has_cmd java; then
    java -version 2>&1 | head -n 1
  fi

  section "Hardware"
  local mem swap disk
  mem="$(memory_gb)"
  swap="$(swap_gb)"
  disk="$(free_disk_gb "$ANDROID_ROOT" 2>/dev/null || echo 0)"

  if [[ "$mem" -ge 16 ]]; then success "RAM looks good: ${mem} GB"; else warn "RAM is low for Android builds: ${mem} GB"; fi
  if [[ "$swap" -ge 8 ]]; then success "Swap looks good: ${swap} GB"; else warn "Swap is low: ${swap} GB"; printf "  Fix: create an 8-16 GB swapfile before large builds.\n"; fi
  if [[ "$disk" -ge 200 ]]; then success "Disk space looks good: ${disk} GB free"; else warn "Free disk may be low: ${disk} GB"; fi

  section "Configured Paths"
  status_path "$ANDROID_ROOT" "Android root" || true
  local device_tree vendor_tree kernel_tree
  device_tree="$(resolve_device_tree)"
  vendor_tree="$(resolve_vendor_tree)"
  kernel_tree="$(resolve_kernel_tree)"
  [[ -n "$device_tree" ]] && status_path "$device_tree" "Device tree" || warn "Device tree not configured"
  [[ -n "$vendor_tree" ]] && status_path "$vendor_tree" "Vendor tree" || warn "Vendor tree not configured"
  [[ -n "$kernel_tree" ]] && status_path "$kernel_tree" "Kernel tree" || warn "Kernel tree not configured"

  section "Result"
  if [[ "$failures" -eq 0 ]]; then
    success "Core environment checks passed"
  else
    warn "$failures required checks need attention"
  fi
}

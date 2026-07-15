#!/usr/bin/env bash
cmd_dashboard() {
  local device_tree vendor_tree kernel_tree last_log last_report
  device_tree="$(resolve_device_tree)"
  vendor_tree="$(resolve_vendor_tree)"
  kernel_tree="$(resolve_kernel_tree)"
  last_log="$(latest_file "$(project_root)/logs" '*.log' || true)"
  last_report="$(latest_file "$(project_root)/reports" '*.md' || true)"

  section "Android ES Dashboard"
  printf "ROM:              %s\n" "$(config_value ROM_NAME)"
  printf "Branch:           %s\n" "$(config_value ROM_BRANCH)"
  printf "Device:           %s\n" "$(config_value DEVICE_CODENAME)"
  printf "Brand:            %s\n" "$(config_value DEVICE_BRAND)"
  printf "Maintainer:       %s\n" "$(config_value MAINTAINER_NAME)"
  printf "Android root:     %s\n" "$(config_value ANDROID_ROOT)"
  printf "Lunch target:     %s\n" "$(config_value LUNCH_TARGET)"
  printf "Build command:    %s\n" "$(config_value BUILD_COMMAND)"
  printf "Jobs:             %s\n" "$(config_value JOBS)"

  section "Workspace"
  [[ -d "$ANDROID_ROOT" ]] && success "Android root found" || warn "Android root not found: $ANDROID_ROOT"
  [[ -n "$device_tree" && -d "$device_tree" ]] && success "Device tree found: $device_tree" || warn "Device tree not found"
  [[ -n "$vendor_tree" && -d "$vendor_tree" ]] && success "Vendor tree found: $vendor_tree" || warn "Vendor tree not found"
  [[ -n "$kernel_tree" && -d "$kernel_tree" ]] && success "Kernel tree found: $kernel_tree" || warn "Kernel tree not found"

  section "System"
  has_cmd git && success "Git ready" || warn "Git missing"
  has_cmd repo && success "Repo tool ready" || warn "Repo tool missing"
  has_cmd adb && success "ADB ready" || warn "ADB missing"
  has_cmd fastboot && success "Fastboot ready" || warn "Fastboot missing"
  printf "Memory:           %s GB\n" "$(memory_gb)"
  printf "Swap:             %s GB\n" "$(swap_gb)"
  printf "Free disk:        %s GB\n" "$(free_disk_gb "$ANDROID_ROOT" 2>/dev/null || echo 0)"

  section "Recent Output"
  [[ -n "$last_log" ]] && printf "Last log:         %s\n" "$last_log" || printf "Last log:         None\n"
  [[ -n "$last_report" ]] && printf "Last report:      %s\n" "$last_report" || printf "Last report:      None\n"
}

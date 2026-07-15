#!/usr/bin/env bash
print_match() {
  local title="$1"
  local reason="$2"
  local fix="$3"
  local file="$4"
  local pattern="$5"
  local match
  match="$(grep -Ein "$pattern" "$file" | head -n 3 || true)"
  [[ -n "$match" ]] || return 1
  section "$title"
  printf "Reason: %s\n" "$reason"
  printf "Suggested check: %s\n" "$fix"
  echo
  printf "%s\n" "$match"
  return 0
}

cmd_log() {
  local action="${1:-analyze}"
  shift || true
  case "$action" in
    analyze)
      local file="${1:-}"
      [[ -n "$file" ]] || die "Usage: ./android-es log analyze <log-file>"
      [[ -f "$file" ]] || die "Log file not found: $file"
      section "Build Log Analysis"
      printf "File: %s\n" "$file"
      local hits=0
      print_match "Missing module" "A module or dependency was referenced but not available." "Check PRODUCT_PACKAGES, Android.bp, local manifests, and vendor tree paths." "$file" "module .* not found|missing dependency|depends on undefined module" && hits=$((hits + 1)) || true
      print_match "Vendor blob issue" "A proprietary file or vendor HAL appears to be missing." "Re-check proprietary-files.txt, re-extract blobs, and inspect vendor makefiles." "$file" "vendor.*not found|proprietary.*missing|cannot find.*vendor|qti.*not found|hardware.*camera.*not found" && hits=$((hits + 1)) || true
      print_match "Sepolicy issue" "SELinux policy failed during build." "Review device sepolicy, private/public split, and neverallow messages." "$file" "neverallow|sepolicy|SELinux|checkpolicy|cil" && hits=$((hits + 1)) || true
      print_match "Soong or Blueprint issue" "Android build metadata has a syntax or dependency problem." "Inspect Android.bp near the matched module and run a smaller build target." "$file" "soong|Android.bp|bootstrap failed|blueprint" && hits=$((hits + 1)) || true
      print_match "Makefile syntax issue" "A makefile likely has indentation, separator, or variable syntax problems." "Inspect the matched .mk file and check tabs/spaces around recipes." "$file" "missing separator|recipe commences before first target|No rule to make target|make: \*\*\*" && hits=$((hits + 1)) || true
      print_match "Ninja failure" "Ninja stopped after another build command failed." "Search above this line for the first real error." "$file" "ninja failed|subcommand failed" && hits=$((hits + 1)) || true
      print_match "Java issue" "Java is missing or incompatible with the ROM branch." "Install the expected JDK and update JAVA_HOME if needed." "$file" "UnsupportedClassVersionError|invalid source release|JAVA_HOME|javac|java.lang" && hits=$((hits + 1)) || true
      print_match "Kernel build issue" "Kernel compilation failed." "Check defconfig, compiler path, ARCH, and the first compiler error above the failure." "$file" "arch/.*/boot|Image.gz|dtbo|DTC|clang: error|gcc: error|ld.lld|vmlinux" && hits=$((hits + 1)) || true
      print_match "Out of memory" "The build may have been killed because memory or swap was too low." "Lower JOBS, increase swap, and retry." "$file" "Killed|out of memory|Cannot allocate memory|oom" && hits=$((hits + 1)) || true
      print_match "Disk space" "The build may have stopped because storage is full." "Free storage in the Android source and output partitions." "$file" "No space left on device|disk full|write error" && hits=$((hits + 1)) || true
      print_match "VINTF issue" "Device/vendor interface metadata failed validation." "Check device manifest, framework matrix, and vendor manifest compatibility." "$file" "VINTF|manifest compatibility|compatibility matrix|checkvintf" && hits=$((hits + 1)) || true

      section "Result"
      if [[ "$hits" -eq 0 ]]; then
        warn "No known pattern matched. Search for the first 'error:' line above the final failure."
        grep -Ein "error:|failed|fatal:" "$file" | head -n 20 || true
      else
        success "$hits issue category/categories matched"
      fi
      ;;
    *)
      die "Unknown log action: $action"
      ;;
  esac
}

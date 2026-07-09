#!/usr/bin/env bash
status_path() {
  local path="$1"
  local label="$2"
  if [[ -e "$path" ]]; then
    success "$label: $path"
    return 0
  fi
  warn "$label missing: $path"
  return 1
}

check_file() {
  local file="$1"
  local label="${2:-$file}"
  if [[ -f "$file" ]]; then
    success "$label"
    return 0
  fi
  warn "$label missing"
  return 1
}

check_dir() {
  local dir="$1"
  local label="${2:-$dir}"
  if [[ -d "$dir" ]]; then
    success "$label"
    return 0
  fi
  warn "$label missing"
  return 1
}

resolve_device_tree() {
  if [[ -n "${DEVICE_TREE:-}" ]]; then
    printf "%s\n" "$DEVICE_TREE"
  elif [[ -n "${DEVICE_BRAND:-}" && -n "${DEVICE_CODENAME:-}" ]]; then
    printf "%s/device/%s/%s\n" "$ANDROID_ROOT" "$DEVICE_BRAND" "$DEVICE_CODENAME"
  else
    printf "\n"
  fi
}

resolve_vendor_tree() {
  if [[ -n "${VENDOR_TREE:-}" ]]; then
    printf "%s\n" "$VENDOR_TREE"
  elif [[ -n "${DEVICE_BRAND:-}" && -n "${DEVICE_CODENAME:-}" ]]; then
    printf "%s/vendor/%s/%s\n" "$ANDROID_ROOT" "$DEVICE_BRAND" "$DEVICE_CODENAME"
  else
    printf "\n"
  fi
}

resolve_kernel_tree() {
  if [[ -n "${KERNEL_TREE:-}" ]]; then
    printf "%s\n" "$KERNEL_TREE"
  elif [[ -n "${DEVICE_BRAND:-}" && -n "${DEVICE_CODENAME:-}" ]]; then
    printf "%s/kernel/%s/%s\n" "$ANDROID_ROOT" "$DEVICE_BRAND" "$DEVICE_CODENAME"
  else
    printf "\n"
  fi
}

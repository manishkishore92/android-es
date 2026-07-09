#!/usr/bin/env bash
CONFIG_FILE="${CONFIG_FILE:-}"
PROFILE_FILE="${PROFILE_FILE:-}"
MAINTAINER_FILE="${MAINTAINER_FILE:-}"

safe_source_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  # shellcheck source=/dev/null
  source "$file"
}

load_all_configs() {
  local root="${ANDROID_ES_ROOT:-$(pwd)}"
  CONFIG_FILE="${CONFIG_FILE:-$root/android-es.config}"
  MAINTAINER_FILE="${MAINTAINER_FILE:-$root/maintainer.conf}"

  safe_source_file "$CONFIG_FILE"
  safe_source_file "$MAINTAINER_FILE"

  if [[ -n "${DEVICE_PROFILE:-}" ]]; then
    PROFILE_FILE="$root/profiles/${DEVICE_PROFILE}.conf"
    safe_source_file "$PROFILE_FILE"
  elif [[ -n "${DEVICE_CODENAME:-}" && -f "$root/profiles/${DEVICE_CODENAME}.conf" ]]; then
    PROFILE_FILE="$root/profiles/${DEVICE_CODENAME}.conf"
    safe_source_file "$PROFILE_FILE"
  fi

  export ANDROID_ROOT="${ANDROID_ROOT:-$HOME/android/source}"
  export DEVICE_CODENAME="${DEVICE_CODENAME:-}"
  export DEVICE_BRAND="${DEVICE_BRAND:-}"
  export ROM_NAME="${ROM_NAME:-Generic Android ROM}"
  export ROM_BRANCH="${ROM_BRANCH:-}"
  export MANIFEST_URL="${MANIFEST_URL:-}"
  export LUNCH_TARGET="${LUNCH_TARGET:-}"
  export BUILD_COMMAND="${BUILD_COMMAND:-mka bacon}"
  export JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"
  export DEVICE_TREE="${DEVICE_TREE:-}"
  export VENDOR_TREE="${VENDOR_TREE:-}"
  export KERNEL_TREE="${KERNEL_TREE:-}"
  export KERNEL_DEFCONFIG="${KERNEL_DEFCONFIG:-}"
  export KERNEL_ARCH="${KERNEL_ARCH:-arm64}"
  export KERNEL_SUBARCH="${KERNEL_SUBARCH:-arm64}"
  export KERNEL_OUT="${KERNEL_OUT:-out}"
  export ANYKERNEL_DIR="${ANYKERNEL_DIR:-}"
  export MAINTAINER_NAME="${MAINTAINER_NAME:-}"
  export MAINTAINER_GITHUB="${MAINTAINER_GITHUB:-}"
}

config_value() {
  local name="$1"
  local fallback="${2:-Not set}"
  local value="${!name:-}"
  if [[ -n "$value" ]]; then
    printf "%s\n" "$value"
  else
    printf "%s\n" "$fallback"
  fi
}

require_config() {
  local name="$1"
  local value="${!name:-}"
  [[ -n "$value" ]] || die "Missing config value: $name"
}

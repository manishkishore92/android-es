#!/usr/bin/env bash
project_root() {
  printf "%s\n" "${ANDROID_ES_ROOT:-$(pwd)}"
}

workspace_file() {
  local name="$1"
  printf "%s/%s\n" "$(project_root)" "$name"
}

ensure_dir() {
  mkdir -p "$1"
}

latest_file() {
  local dir="$1"
  local pattern="$2"
  if [[ -d "$dir" ]]; then
    find "$dir" -type f -name "$pattern" -printf '%T@ %p\n' 2>/dev/null | sort -nr | awk 'NR==1 {sub(/^[^ ]+ /, ""); print}'
  fi
}

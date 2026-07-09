#!/usr/bin/env bash
has_cmd() { command -v "$1" >/dev/null 2>&1; }

check_cmd() {
  local cmd="$1"
  local fix="${2:-Install package: $cmd}"
  if has_cmd "$cmd"; then
    success "$cmd found"
    return 0
  fi
  error "$cmd missing"
  printf "  Fix: %s\n" "$fix"
  return 1
}

human_bytes() {
  local bytes="${1:-0}"
  awk -v b="$bytes" 'BEGIN {
    split("B KB MB GB TB", u);
    i=1;
    while (b>=1024 && i<5) { b/=1024; i++ }
    printf "%.2f %s", b, u[i]
  }'
}

free_disk_gb() {
  local path="${1:-.}"
  df -BG "$path" 2>/dev/null | awk 'NR==2 {gsub("G", "", $4); print $4}'
}

memory_gb() {
  awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo 0
}

swap_gb() {
  awk '/SwapTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo 0
}

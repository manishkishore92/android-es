#!/usr/bin/env bash
collect_git_log() {
  local title="$1"
  local path="$2"
  local count="${3:-20}"
  echo "## $title"
  echo
  if [[ -d "$path/.git" ]]; then
    (cd "$path" && git log --pretty=format:'- %s (%h)' -n "$count") || true
    echo
  else
    echo "- No git history found at $path"
  fi
  echo
}

cmd_changelog() {
  local action="${1:-generate}"
  case "$action" in
    generate)
      local out device_tree vendor_tree kernel_tree
      device_tree="$(resolve_device_tree)"
      vendor_tree="$(resolve_vendor_tree)"
      kernel_tree="$(resolve_kernel_tree)"
      ensure_dir "$(project_root)/changelogs"
      out="$(project_root)/changelogs/${DEVICE_CODENAME:-device}-$(date +%Y%m%d-%H%M%S).md"
      {
        echo "# Changelog"
        echo
        echo "Device: ${DEVICE_CODENAME:-Not set}"
        echo "Generated: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
        echo
        collect_git_log "Device Tree" "$device_tree" 25
        collect_git_log "Vendor Tree" "$vendor_tree" 25
        collect_git_log "Kernel Tree" "$kernel_tree" 25
        if [[ -d "$ANDROID_ROOT/.git" ]]; then
          collect_git_log "ROM Source" "$ANDROID_ROOT" 25
        fi
      } > "$out"
      success "Changelog created: $out"
      ;;
    *)
      die "Unknown changelog action: $action"
      ;;
  esac
}

#!/usr/bin/env bash
cmd_backup() {
  local action="${1:-create}"
  shift || true
  case "$action" in
    create)
      local out staging root
      root="$(project_root)"
      ensure_dir "$root/backups"
      staging="$(mktemp -d)"
      mkdir -p "$staging/android-es-backup"
      for item in android-es.config maintainer.conf profiles logs reports releases changelogs ota; do
        if [[ -e "$root/$item" ]]; then
          cp -a "$root/$item" "$staging/android-es-backup/"
        fi
      done
      if [[ -d "$ANDROID_ROOT/.repo/local_manifests" ]]; then
        mkdir -p "$staging/android-es-backup/local_manifests"
        cp -a "$ANDROID_ROOT/.repo/local_manifests/." "$staging/android-es-backup/local_manifests/"
      fi
      out="$root/backups/android-es-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
      tar -C "$staging" -czf "$out" android-es-backup
      rm -rf "$staging"
      success "Backup created: $out"
      ;;
    restore)
      local archive="${1:-}"
      [[ -n "$archive" && -f "$archive" ]] || die "Usage: ./android-es backup restore <archive.tar.gz>"
      tar -xzf "$archive" -C "$(project_root)"
      success "Backup extracted into $(project_root)/android-es-backup"
      ;;
    *)
      die "Unknown backup action: $action"
      ;;
  esac
}

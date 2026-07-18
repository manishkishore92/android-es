#!/usr/bin/env bash
cmd_source() {
  local action="${1:-status}"
  case "$action" in
    init)
      require_config MANIFEST_URL
      require_config ROM_BRANCH
      ensure_dir "$ANDROID_ROOT"
      cd "$ANDROID_ROOT"
      info "Initializing source in $ANDROID_ROOT"
      repo init -u "$MANIFEST_URL" -b "$ROM_BRANCH"
      success "Source initialized"
      ;;
    sync)
      [[ -d "$ANDROID_ROOT/.repo" ]] || die "Repo metadata not found. Run: ./android-es source init"
      cd "$ANDROID_ROOT"
      info "Syncing source with $JOBS jobs"
      repo sync -c --force-sync --no-clone-bundle --no-tags -j"$JOBS"
      success "Source sync finished"
      ;;
    status)
      section "Source Status"
      printf "Android root:  %s\n" "$ANDROID_ROOT"
      printf "Manifest URL:  %s\n" "$(config_value MANIFEST_URL)"
      printf "Branch:        %s\n" "$(config_value ROM_BRANCH)"
      if [[ -d "$ANDROID_ROOT/.repo" ]]; then
        success "Repo metadata found"
      else
        warn "Repo metadata not found"
      fi
      if [[ -d "$ANDROID_ROOT/.repo/local_manifests" ]]; then
        info "Local manifests: $ANDROID_ROOT/.repo/local_manifests"
        find "$ANDROID_ROOT/.repo/local_manifests" -maxdepth 1 -type f -name '*.xml' -print
      fi
      ;;
    *)
      die "Unknown source action: $action"
      ;;
  esac
}

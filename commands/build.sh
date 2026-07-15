#!/usr/bin/env bash
cmd_build() {
  local action="${1:-rom}"
  case "$action" in
    rom)
      [[ -d "$ANDROID_ROOT" ]] || die "Android root not found: $ANDROID_ROOT"
      [[ -f "$ANDROID_ROOT/build/envsetup.sh" ]] || die "build/envsetup.sh not found in Android root"
      [[ -n "$LUNCH_TARGET" ]] || die "LUNCH_TARGET is not configured"
      local log_dir log_file start_ts end_ts status report
      log_dir="$(project_root)/logs"
      ensure_dir "$log_dir"
      log_file="$log_dir/build-${DEVICE_CODENAME:-device}-$(date +%Y%m%d-%H%M%S).log"
      start_ts="$(date +%s)"
      cd "$ANDROID_ROOT"
      info "Starting ROM build"
      info "Log: $log_file"
      set +e
      bash -lc "source build/envsetup.sh && lunch '$LUNCH_TARGET' && $BUILD_COMMAND -j'$JOBS'" 2>&1 | tee "$log_file"
      status="${PIPESTATUS[0]}"
      set -e
      end_ts="$(date +%s)"
      report="$(project_root)/reports/build-${DEVICE_CODENAME:-device}-$(date +%Y%m%d-%H%M%S).md"
      ensure_dir "$(dirname "$report")"
      {
        echo "# Build Report"
        echo
        echo "| Field | Value |"
        echo "| --- | --- |"
        echo "| ROM | $ROM_NAME |"
        echo "| Device | ${DEVICE_CODENAME:-Not set} |"
        echo "| Lunch target | $LUNCH_TARGET |"
        echo "| Build command | $BUILD_COMMAND |"
        echo "| Status | $([[ "$status" -eq 0 ]] && echo Success || echo Failed) |"
        echo "| Duration | $((end_ts - start_ts)) seconds |"
        echo "| Log | $log_file |"
        echo
        echo "## Last log lines"
        echo
        echo '```text'
        tail -n 80 "$log_file" || true
        echo '```'
      } > "$report"
      if [[ "$status" -eq 0 ]]; then
        success "ROM build finished"
      else
        warn "ROM build failed. Analyze it with: ./android-es log analyze $log_file"
      fi
      info "Report: $report"
      return "$status"
      ;;
    *)
      die "Unknown build action: $action"
      ;;
  esac
}

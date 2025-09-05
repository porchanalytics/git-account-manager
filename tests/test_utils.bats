#!/usr/bin/env bats

# Test the core utilities and functions

load test_helper

@test "gam_cmd_exists detects available commands" {
  run gam_cmd_exists "bash"
  [ "$status" -eq 0 ]
  
  run gam_cmd_exists "nonexistent_command_xyz123"
  [ "$status" -eq 1 ]
}

@test "gam_log_audit creates log entries when enabled" {
  setup_test_config
  export GAM_AUDIT=1
  export GAM_LOG_FILE="$BATS_TMPDIR/test.log"
  
  run gam_log_audit "test action"
  [ "$status" -eq 0 ]
  [ -f "$GAM_LOG_FILE" ]
  grep -q "test action" "$GAM_LOG_FILE"
}

@test "gam_log_audit skips logging when disabled" {
  export GAM_AUDIT=0
  export GAM_LOG_FILE="$BATS_TMPDIR/test.log"
  
  run gam_log_audit "test action"
  [ "$status" -eq 0 ]
  [ ! -f "$GAM_LOG_FILE" ]
}

@test "gam_die outputs error and returns 1" {
  run gam_die "test error"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "test error" ]]
}

@test "gam_git_root returns git root directory" {
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  
  run gam_git_root
  [ "$status" -eq 0 ]
  [ "$output" = "$BATS_TMPDIR/test_repo" ]
}

@test "gam_require_git_repo succeeds inside git repo" {
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  
  run gam_require_git_repo
  [ "$status" -eq 0 ]
}

@test "gam_require_git_repo fails outside git repo" {
  cd "$BATS_TMPDIR"
  
  run gam_require_git_repo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Not inside a git repository" ]]
}
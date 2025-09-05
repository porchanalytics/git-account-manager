#!/usr/bin/env bats

# Test doctor functionality

load test_helper

@test "git-doctor command exists" {
  run command -v git-doctor
  [ "$status" -eq 0 ]
}

@test "git-doctor shows help with --help" {
  run git-doctor --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage" ]]
}

@test "git-doctor checks SSH configuration" {
  setup_test_config
  
  run git-doctor
  # Should run even if it finds issues
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
  # Should mention SSH hosts in output
  [[ "$output" =~ "SSH" ]] || [[ "$output" =~ "host" ]]
}

@test "git-doctor checks audit log directory" {
  setup_test_config
  export GAM_LOG_FILE="$BATS_TMPDIR/nonexistent/audit.log"
  
  run git-doctor
  # Should handle missing log directory gracefully
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "git-doctor works in git repository" {
  setup_test_config
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  
  run git-doctor
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
  # Should check repository health
  [[ "$output" =~ "branch" ]] || [[ "$output" =~ "commit" ]]
}

@test "git-doctor works outside git repository" {
  setup_test_config
  cd "$BATS_TMPDIR"
  
  run git-doctor
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
  # Should still run basic checks
}

@test "git-validate alias works" {
  setup_test_config
  
  run git-validate
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}
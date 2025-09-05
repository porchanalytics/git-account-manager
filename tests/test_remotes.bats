#!/usr/bin/env bats

# Test remote management functionality

load test_helper

@test "git-remote-set command exists" {
  run command -v git-remote-set
  [ "$status" -eq 0 ]
}

@test "git-remote-personal command exists" {
  run command -v git-remote-personal
  [ "$status" -eq 0 ]
}

@test "git-remote-business command exists" {
  run command -v git-remote-business
  [ "$status" -eq 0 ]
}

@test "git-remote-set shows help with --help" {
  run git-remote-set --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage" ]] || [[ "$output" =~ "account" ]]
}

@test "git-remote-personal sets personal remote" {
  setup_test_config
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  
  run git-remote-personal test-repo
  [ "$status" -eq 0 ]
  
  # Check remote was set
  remote_url=$(git remote get-url origin 2>/dev/null || echo "")
  [[ "$remote_url" =~ "$GAM_PERSONAL_SSH_HOST" ]] || [[ "$remote_url" =~ "$GAM_PERSONAL_GITHUB" ]]
}

@test "git-remote-business sets business remote" {
  setup_test_config
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  
  run git-remote-business test-repo
  [ "$status" -eq 0 ]
  
  # Check remote was set
  remote_url=$(git remote get-url origin 2>/dev/null || echo "")
  [[ "$remote_url" =~ "$GAM_BUSINESS_SSH_HOST" ]] || [[ "$remote_url" =~ "$GAM_BUSINESS_GITHUB" ]]
}

@test "git-remote-set with explicit parameters" {
  setup_test_config
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  
  run git-remote-set --account personal --owner testowner --repo testrepo
  [ "$status" -eq 0 ]
  
  # Check remote was set correctly
  remote_url=$(git remote get-url origin 2>/dev/null || echo "")
  [[ "$remote_url" =~ "testowner" ]]
  [[ "$remote_url" =~ "testrepo" ]]
}
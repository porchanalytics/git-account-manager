#!/usr/bin/env bats

# Test comprehensive whoami and identity functions

load test_helper

@test "git-whoami command exists" {
  run command -v git-whoami
  [ "$status" -eq 0 ]
}

@test "git-whoami shows current identity in git repo" {
  setup_test_config
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  
  # Set identity first
  use-personal
  
  run git-whoami
  [ "$status" -eq 0 ]
  [[ "$output" =~ "$GAM_PERSONAL_NAME" ]]
  [[ "$output" =~ "$GAM_PERSONAL_EMAIL" ]]
}

@test "git-whoami works outside git repo" {
  setup_test_config
  cd "$BATS_TMPDIR"
  
  run git-whoami
  [ "$status" -eq 0 ]
  # Should show global config or "Not in a git repository"
}

@test "git-personal-global sets global config" {
  setup_test_config
  
  run git-personal-global
  [ "$status" -eq 0 ]
  
  # Check global git config
  name=$(git config --global user.name)
  email=$(git config --global user.email)
  [ "$name" = "$GAM_PERSONAL_NAME" ]
  [ "$email" = "$GAM_PERSONAL_EMAIL" ]
}

@test "git-business-global sets global config" {
  setup_test_config
  
  run git-business-global
  [ "$status" -eq 0 ]
  
  # Check global git config
  name=$(git config --global user.name)
  email=$(git config --global user.email)
  [ "$name" = "$GAM_BUSINESS_NAME" ]
  [ "$email" = "$GAM_BUSINESS_EMAIL" ]
}

@test "git-remote-info shows remote information" {
  setup_test_config
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  
  # Add a remote
  git remote add origin https://github.com/test/repo.git
  
  run git-remote-info
  [ "$status" -eq 0 ]
  [[ "$output" =~ "origin" ]]
  [[ "$output" =~ "github.com" ]]
}

@test "git-list-ssh-keys shows SSH key information" {
  run git-list-ssh-keys
  [ "$status" -eq 0 ]
  # Should either show keys or indicate none are loaded
}
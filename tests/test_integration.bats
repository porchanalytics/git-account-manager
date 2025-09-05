#!/usr/bin/env bats

# Integration tests for git-account-manager

load test_helper

@test "git-account-manager.sh can be sourced" {
  run bash -c "source '${GAM_ROOT}/bin/git-account-manager.sh' && echo 'loaded'"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "loaded" ]]
}

@test "all main commands are available after sourcing" {
  source "${GAM_ROOT}/bin/git-account-manager.sh"
  
  # Test that main commands exist
  run command -v use-personal
  [ "$status" -eq 0 ]
  
  run command -v use-business
  [ "$status" -eq 0 ]
  
  run command -v git-whoami
  [ "$status" -eq 0 ]
  
  run command -v git-doctor
  [ "$status" -eq 0 ]
  
  run command -v git-help
  [ "$status" -eq 0 ]
}

@test "color variables are available" {
  source "${GAM_ROOT}/bin/git-account-manager.sh"
  
  # Test that color variables are defined
  [ -n "${C_RESET:-}" ]
  [ -n "${SYM_CHECK:-}" ]
  [ -n "${SYM_ARROW:-}" ]
}

@test "config loading works with XDG paths" {
  setup_test_config
  export XDG_CONFIG_HOME="$BATS_TMPDIR/.config"
  mkdir -p "$XDG_CONFIG_HOME/git-account-manager"
  
  # Create a test config
  cat > "$XDG_CONFIG_HOME/git-account-manager/config.sh" << EOF
GAM_PERSONAL_NAME="XDG Test User"
GAM_PERSONAL_EMAIL="xdg@example.com"
EOF
  
  # Source the main script
  source "${GAM_ROOT}/bin/git-account-manager.sh"
  
  # Check that config was loaded
  [ "$GAM_PERSONAL_NAME" = "XDG Test User" ]
  [ "$GAM_PERSONAL_EMAIL" = "xdg@example.com" ]
}

@test "full workflow: setup identity and switch accounts" {
  setup_test_config
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  
  # Test switching to personal
  run use-personal
  [ "$status" -eq 0 ]
  
  name=$(git config user.name)
  email=$(git config user.email)
  [ "$name" = "$GAM_PERSONAL_NAME" ]
  [ "$email" = "$GAM_PERSONAL_EMAIL" ]
  
  # Test switching to business
  run use-business
  [ "$status" -eq 0 ]
  
  name=$(git config user.name)
  email=$(git config user.email)
  [ "$name" = "$GAM_BUSINESS_NAME" ]
  [ "$email" = "$GAM_BUSINESS_EMAIL" ]
  
  # Test git-whoami shows current identity
  run git-whoami
  [ "$status" -eq 0 ]
  [[ "$output" =~ "$GAM_BUSINESS_NAME" ]]
  [[ "$output" =~ "$GAM_BUSINESS_EMAIL" ]]
}

@test "error handling: functions work outside git repo" {
  setup_test_config
  cd "$BATS_TMPDIR"
  
  # These should not fail even outside a git repo
  run git-help
  [ "$status" -eq 0 ]
  
  run git-doctor
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
  
  run git-whoami
  [ "$status" -eq 0 ]
}
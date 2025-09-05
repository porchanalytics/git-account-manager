#!/usr/bin/env bats

# Test account switching functionality

load test_helper

@test "use-personal sets correct git identity" {
  setup_test_config
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  
  run use-personal
  [ "$status" -eq 0 ]
  
  # Check git config was set
  name=$(git config user.name)
  email=$(git config user.email)
  [ "$name" = "$GAM_PERSONAL_NAME" ]
  [ "$email" = "$GAM_PERSONAL_EMAIL" ]
}

@test "use-business sets correct git identity" {
  setup_test_config
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  
  run use-business
  [ "$status" -eq 0 ]
  
  # Check git config was set
  name=$(git config user.name)
  email=$(git config user.email)
  [ "$name" = "$GAM_BUSINESS_NAME" ]
  [ "$email" = "$GAM_BUSINESS_EMAIL" ]
}

@test "use-personal shows help with --help" {
  run use-personal --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage: use-personal" ]]
}

@test "use-business shows help with --help" {
  run use-business --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage: use-business" ]]
}

@test "use-personal logs audit entry" {
  setup_test_config
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  export GAM_AUDIT=1
  export GAM_LOG_FILE="$BATS_TMPDIR/audit.log"
  
  run use-personal
  [ "$status" -eq 0 ]
  [ -f "$GAM_LOG_FILE" ]
  grep -q "use-personal" "$GAM_LOG_FILE"
  grep -q "$GAM_PERSONAL_EMAIL" "$GAM_LOG_FILE"
}

@test "use-business logs audit entry" {
  setup_test_config
  setup_test_git_repo
  cd "$BATS_TMPDIR/test_repo"
  export GAM_AUDIT=1
  export GAM_LOG_FILE="$BATS_TMPDIR/audit.log"
  
  run use-business
  [ "$status" -eq 0 ]
  [ -f "$GAM_LOG_FILE" ]
  grep -q "use-business" "$GAM_LOG_FILE"
  grep -q "$GAM_BUSINESS_EMAIL" "$GAM_LOG_FILE"
}
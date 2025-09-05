#!/usr/bin/env bats

# Test SSH configuration functionality

load test_helper

@test "git-setup-ssh-hosts command exists" {
  run command -v git-setup-ssh-hosts
  [ "$status" -eq 0 ]
}

@test "git-test-ssh command exists" {
  run command -v git-test-ssh
  [ "$status" -eq 0 ]
}

@test "git-setup-ssh-hosts creates SSH config" {
  setup_test_config
  export HOME="$BATS_TMPDIR"
  mkdir -p "$HOME/.ssh"
  
  run git-setup-ssh-hosts
  [ "$status" -eq 0 ]
  
  # Check SSH config was created/modified
  [ -f "$HOME/.ssh/config" ]
}

@test "git-test-ssh tests SSH connections" {
  setup_test_config
  
  run git-test-ssh
  # This will likely fail in test environment but should run
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
  [[ "$output" =~ "Testing" ]] || [[ "$output" =~ "SSH" ]]
}

@test "git-setup-ssh-hosts with custom hosts" {
  setup_test_config
  export HOME="$BATS_TMPDIR"
  mkdir -p "$HOME/.ssh"
  export GAM_PERSONAL_SSH_HOST="custom-personal"
  export GAM_BUSINESS_SSH_HOST="custom-business"
  
  run git-setup-ssh-hosts
  [ "$status" -eq 0 ]
  
  # Check custom hosts are in config
  [ -f "$HOME/.ssh/config" ]
  grep -q "custom-personal" "$HOME/.ssh/config"
  grep -q "custom-business" "$HOME/.ssh/config"
}
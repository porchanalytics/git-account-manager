#!/usr/bin/env bash

# Test helper functions for git-account-manager tests

# Load the git-account-manager library
export GAM_ROOT="${BATS_TEST_DIRNAME}/.."
source "${GAM_ROOT}/bin/git-account-manager.sh"

# Setup test configuration
setup_test_config() {
  export GAM_PERSONAL_NAME="Test Personal"
  export GAM_PERSONAL_EMAIL="personal@example.com"
  export GAM_PERSONAL_GITHUB="personal-user"
  export GAM_PERSONAL_SSH_HOST="github-personal"
  export GAM_PERSONAL_SSH_KEY="$HOME/.ssh/id_ed25519_personal"
  
  export GAM_BUSINESS_NAME="Test Business"
  export GAM_BUSINESS_EMAIL="business@example.com"
  export GAM_BUSINESS_GITHUB="business-user"
  export GAM_BUSINESS_SSH_HOST="github-business"
  export GAM_BUSINESS_SSH_KEY="$HOME/.ssh/id_ed25519_business"
  
  export GAM_AUDIT=1
  export GAM_ENFORCE=0
  export GAM_AUTO_FIX=0
}

# Setup a test git repository
setup_test_git_repo() {
  mkdir -p "$BATS_TMPDIR/test_repo"
  cd "$BATS_TMPDIR/test_repo"
  git init --quiet
  git config user.name "Initial Test User"
  git config user.email "test@example.com"
  echo "# Test Repository" > README.md
  git add README.md
  git commit --quiet -m "Initial commit"
}

# Clean up test files
teardown_test() {
  # Clean up any test repositories
  rm -rf "$BATS_TMPDIR/test_repo" 2>/dev/null || true
  # Clean up test SSH configs
  rm -rf "$BATS_TMPDIR/.ssh" 2>/dev/null || true
  # Clean up test logs
  rm -f "$BATS_TMPDIR"/*.log 2>/dev/null || true
}

# Setup function called before each test
setup() {
  # Ensure we have a clean environment
  export BATS_TMPDIR="${BATS_TMPDIR:-/tmp}"
  # Don't pollute user's actual git config during tests
  export GIT_CONFIG_GLOBAL="$BATS_TMPDIR/test_gitconfig"
  # Create empty global config for tests
  echo "[user]" > "$GIT_CONFIG_GLOBAL"
  echo "    name = Test User" >> "$GIT_CONFIG_GLOBAL"
  echo "    email = test@example.com" >> "$GIT_CONFIG_GLOBAL"
}

# Teardown function called after each test
teardown() {
  teardown_test
  # Clean up global test config
  rm -f "$GIT_CONFIG_GLOBAL" 2>/dev/null || true
}
#!/usr/bin/env bash
# When sourced, do not alter shell options/IFS globally.
if ! (return 0 2>/dev/null); then
  set -Eeuo pipefail
  IFS=$'\n\t'
fi

# Expected in private config:
# GAM_PERSONAL_NAME, GAM_PERSONAL_EMAIL, GAM_PERSONAL_SSH_HOST, GAM_PERSONAL_SSH_KEY
# GAM_BUSINESS_NAME, GAM_BUSINESS_EMAIL, GAM_BUSINESS_SSH_HOST, GAM_BUSINESS_SSH_KEY

gam__apply_identity() { # <name> <email>
  git config user.name "$1"
  git config user.email "$2"
}

use-personal() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: use-personal"; return 0; }
  local name="${GAM_PERSONAL_NAME:-Personal User}"
  local email="${GAM_PERSONAL_EMAIL:-[email protected]}"
  gam__apply_identity "${name}" "${email}"
  gam_log_audit "use-personal repo=$(pwd) email=${email}"
  printf 'Switched identity to %s <%s>\n' "${name}" "${email}"
}

use-business() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: use-business"; return 0; }
  local name="${GAM_BUSINESS_NAME:-Business User}"
  local email="${GAM_BUSINESS_EMAIL:-[email protected]}"
  gam__apply_identity "${name}" "${email}"
  gam_log_audit "use-business repo=$(pwd) email=${email}"
  printf 'Switched identity to %s <%s>\n' "${name}" "${email}"
}


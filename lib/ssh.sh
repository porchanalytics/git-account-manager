#!/usr/bin/env bash
if ! (return 0 2>/dev/null); then
  set -Eeuo pipefail
  IFS=$'\n\t'
fi

git-setup-ssh-hosts() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-setup-ssh-hosts"; return 0; }
  local cfg="$HOME/.ssh/config"
  mkdir -p "$(dirname "${cfg}")"
  touch "${cfg}"
  # Use values from config if provided, else defaults
  local p_host="${GAM_PERSONAL_SSH_HOST:-github-personal}"
  local b_host="${GAM_BUSINESS_SSH_HOST:-github-business}"
  local p_key="${GAM_PERSONAL_SSH_KEY:-$HOME/.ssh/id_ed25519_personal}"
  local b_key="${GAM_BUSINESS_SSH_KEY:-$HOME/.ssh/id_ed25519_business}"
  
  # Expand tilde in paths
  p_key="${p_key/#\~/$HOME}"
  b_key="${b_key/#\~/$HOME}"
  
  # Validate SSH keys exist
  local missing_keys=0
  if [[ ! -f "${p_key}" ]]; then
    printf '%s%s Warning: Personal SSH key not found: %s%s\n' "${C_YELLOW}" "${SYM_WARNING}" "${p_key}" "${C_RESET}" >&2
    missing_keys=1
  fi
  if [[ ! -f "${b_key}" ]]; then
    printf '%s%s Warning: Business SSH key not found: %s%s\n' "${C_YELLOW}" "${SYM_WARNING}" "${b_key}" "${C_RESET}" >&2
    missing_keys=1
  fi
  
  if [[ $missing_keys -eq 1 ]]; then
    printf '%s%s Generate missing keys with:%s\n' "${C_YELLOW}" "${SYM_INFO}" "${C_RESET}" >&2
    [[ ! -f "${p_key}" ]] && printf '  ssh-keygen -t ed25519 -C "personal" -f %q\n' "${p_key}" >&2
    [[ ! -f "${b_key}" ]] && printf '  ssh-keygen -t ed25519 -C "business" -f %q\n' "${b_key}" >&2
  fi
  
  # Idempotently append blocks
  for pair in "${p_host}:${p_key}" "${b_host}:${b_key}"; do
    host="${pair%%:*}"; key="${pair##*:}"
    if ! grep -qE "^Host[[:space:]]+${host}\b" "${cfg}"; then
      cat >> "${cfg}" <<EOF
Host ${host}
  HostName github.com
  User git
  IdentityFile ${key}
  IdentitiesOnly yes
EOF
      printf 'Wrote SSH host alias: %s -> %s\n' "${host}" "${key}"
    fi
  done
}


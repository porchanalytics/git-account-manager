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


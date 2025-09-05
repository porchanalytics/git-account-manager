#!/usr/bin/env bash
if ! (return 0 2>/dev/null); then
  set -Eeuo pipefail
  IFS=$'\n\t'
fi

_gam_usage_remote_set() {
  cat <<'EOF'
Usage: git-remote-set --account personal|business --owner <OWNER> --repo <REPO>
Example:
  git-remote-set --account personal --owner myuser --repo widgets
EOF
}

git-origin() {
  local url; url="$(git remote get-url origin 2>/dev/null || true)"
  if [[ -z "${url}" ]]; then echo "No origin remote."; return 1; fi
  local host; host="$(gam_current_remote_host || true)"
  local acct; acct="$(gam_account_from_host "${host}")"
  printf 'origin: %s\naccount: %s\n' "${url}" "${acct}"
}

git-remote-set() {
  local account="" owner="" repo=""
  while (( "$#" )); do
    case "$1" in
      --account) account="${2:?}"; shift 2;;
      --owner) owner="${2:?}"; shift 2;;
      --repo) repo="${2:?}"; shift 2;;
      -h|--help) _gam_usage_remote_set; return 0;;
      *) echo "Unknown flag: $1"; _gam_usage_remote_set; return 1;;
    esac
  done
  [[ -z "${account}" || -z "${owner}" || -z "${repo}" ]] && { _gam_usage_remote_set; return 1; }
  local host
  case "${account}" in
    personal) host="${GAM_PERSONAL_SSH_HOST:-github-personal}";;
    business) host="${GAM_BUSINESS_SSH_HOST:-github-business}";;
    *) gam_die "Unknown account: ${account} (expected personal|business)";;
  esac
  local url="git@${host}:${owner}/${repo}.git"
  if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "${url}"
  else
    git remote add origin "${url}"
  fi
  gam_log_audit "remote-set account=${account} url=${url}"
  printf 'Set origin to %s\n' "${url}"
}

git-origin-personal() { git-remote-set --account personal --owner "${1:?owner}" --repo "${2:-${1##*/}}"; }
git-origin-business() { git-remote-set --account business --owner "${1:?owner}" --repo "${2:-${1##*/}}"; }


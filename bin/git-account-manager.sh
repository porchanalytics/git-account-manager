#!/usr/bin/env bash
# Entry point: source this file from your shell to expose commands:
#   source /path/to/git-account-manager/bin/git-account-manager.sh
# Be shell-agnostic when sourced by zsh or bash. Do NOT change shell options
# or IFS globally when sourced from an interactive shell.

# Determine repo root robustly across shells.
if [ -z "${GAM_ROOT:-}" ]; then
  if [ -n "${BASH_VERSION:-}" ]; then
    _gam_src="${BASH_SOURCE[0]}"
  else
    _gam_src="$0"
  fi
  case "${_gam_src}" in
    /*) GAM_ROOT="$(cd "$(dirname "${_gam_src}")/.." && pwd)" ;;
    */*) GAM_ROOT="$(cd "$(pwd)/$(dirname "${_gam_src}")/.." && pwd)" ;;
    *) GAM_ROOT="${GAM_ROOT:-$HOME/.config/git-account-manager}" ;;
  esac
fi
# shellcheck disable=SC1091
. "${GAM_ROOT}/lib/colors.sh"
# shellcheck disable=SC1091
. "${GAM_ROOT}/lib/utils.sh"
# shellcheck disable=SC1091
. "${GAM_ROOT}/lib/help.sh"
# shellcheck disable=SC1091
. "${GAM_ROOT}/lib/accounts.sh"
# shellcheck disable=SC1091
. "${GAM_ROOT}/lib/remotes.sh"
# shellcheck disable=SC1091
. "${GAM_ROOT}/lib/clone-init.sh"
# shellcheck disable=SC1091
. "${GAM_ROOT}/lib/ssh.sh"
# shellcheck disable=SC1091
. "${GAM_ROOT}/lib/guard.sh"
# shellcheck disable=SC1091
. "${GAM_ROOT}/lib/doctor.sh"
# shellcheck disable=SC1091
. "${GAM_ROOT}/lib/comprehensive.sh"

# Load private config (never committed). Prefer XDG config;
# fall back to repo root config.sh for transition.
_GAM_XDG_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/git-account-manager/config.sh"
if [[ -f "${_GAM_XDG_CFG}" ]]; then
  # shellcheck disable=SC1090
  . "${_GAM_XDG_CFG}"
elif [[ -f "${GAM_ROOT}/config.sh" ]]; then
  # shellcheck disable=SC1090
  . "${GAM_ROOT}/config.sh"
fi

# Post-load: export public commands (functions are visible in current shell)
# Command list lives in lib/help.sh (git-help / git-usage)
:

# Optional convenience alias to run the repo's doctor script directly
git-validate() { git-doctor "$@"; }

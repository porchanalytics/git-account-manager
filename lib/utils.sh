#!/usr/bin/env bash
if ! (return 0 2>/dev/null); then
  set -Eeuo pipefail
  IFS=$'\n\t'
fi

# Colors available after colors.sh, but safe fallbacks:
: "${C_BOLD:=}"; : "${C_RESET:=}"; : "${C_GREEN:=}"; : "${C_RED:=}"; : "${C_YELLOW:=}"
: "${C_BLUE:=}"; : "${C_MAGENTA:=}"; : "${C_CYAN:=}"; : "${C_WHITE:=}"; : "${C_DIM:=}"
: "${BOX_H:=-}"; : "${BOX_V:=|}"; : "${SYM_CHECK:=+}"; : "${SYM_CROSS:=x}"; : "${SYM_ARROW:=->}"

gam_cmd_exists() { command -v "$1" >/dev/null 2>&1; }

# XDG paths
# shellcheck disable=SC2034  # Variables used in other files
GAM_CONFIG_FILE_DEFAULT="${XDG_CONFIG_HOME:-$HOME/.config}/git-account-manager/config.sh"
GAM_STATE_DIR_DEFAULT="${XDG_STATE_HOME:-$HOME/.local/state}/git-account-manager"
# shellcheck disable=SC2034  # Variables used in other files via GAM_DATA_DIR_FALLBACK
GAM_DATA_DIR_FALLBACK="${XDG_DATA_HOME:-$HOME/.local/share}/git-account-manager"
GAM_LOG_FILE="${GAM_LOG_FILE:-${GAM_STATE_DIR_DEFAULT}/audit.log}"
GAM_AUDIT="${GAM_AUDIT:-1}"

gam__ensure_log_dir() {
  local dir; dir="$(dirname "${GAM_LOG_FILE}")"
  if ! mkdir -p "${dir}" 2>/dev/null; then
    printf 'Warning: Could not create audit log directory: %s\n' "${dir}" >&2
    return 1
  fi
  return 0
}

gam_log_audit() {
  [[ "${GAM_AUDIT}" = "0" ]] && return 0
  gam__ensure_log_dir || return 0  # Silently skip logging if dir creation fails
  # shellcheck disable=SC2155
  local ts="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf '%s %s\n' "${ts}" "$*" >> "${GAM_LOG_FILE}" 2>/dev/null || return 0
}

gam_die() { printf '%sError:%s %s\n' "${C_RED}" "${C_RESET}" "$*" >&2; return 1; }
gam_info() { printf '%s%s%s\n' "${C_BOLD}" "$*" "${C_RESET}"; }
gam_warn() { printf '%sWarning:%s %s\n' "${C_YELLOW}" "${C_RESET}" "$*" >&2; }

gam_git_root() {
  git rev-parse --show-toplevel 2>/dev/null || true
}

gam_require_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || gam_die "Not inside a git repository."
}

gam_default_branch_or_main() {
  if git show-ref --verify --quiet refs/heads/main; then
    printf 'main\n'
  else
    # Fallback to symbolic HEAD or master
    git symbolic-ref --quiet --short HEAD 2>/dev/null || printf 'main\n'
  fi
}

gam_parse_repo_arg() { # input → prints "OWNER REPO"
  # Accepts: OWNER/REPO, https://github.com/OWNER/REPO(.git), git@github.com:OWNER/REPO(.git)
  local in="$1"
  [[ -z "${in}" ]] && { gam_die "Empty repository argument"; return 1; }
  
  # Remove .git suffix if present
  in="${in%.git}"
  
  # Handle various URL formats
  case "${in}" in
    https://github.com/*/*|http://github.com/*/*)
      in="${in#*github.com/}"
      ;;
    git@github.com:*/*)
      in="${in#git@github.com:}"
      ;;
    git@*:*/*)
      # Handle custom SSH host aliases
      in="${in#git@*:}"
      ;;
    ssh://git@*/*)
      in="${in#ssh://git@*/}"
      in="${in#*/}"  # Skip hostname
      ;;
  esac
  
  # Validate format
  if [[ "${in}" != */* ]]; then
    gam_die "Expected OWNER/REPO format but got: ${in}"
    return 1
  fi
  
  local owner="${in%/*}"
  local repo="${in##*/}"
  
  # Validate non-empty
  if [[ -z "${owner}" || -z "${repo}" ]]; then
    gam_die "Invalid repository format: owner or repo is empty"
    return 1
  fi
  
  printf '%s %s\n' "${owner}" "${repo}"
}

gam_repo_has_commit() {
  git rev-parse --verify HEAD >/dev/null 2>&1
}

gam_git_add_initial_commit_if_needed() {
  if ! gam_repo_has_commit; then
    # Ensure there's something to commit: if index and worktree are empty, seed README
    if [[ -z "$(git ls-files)" ]] && [[ -z "$(git status --porcelain)" ]]; then
      echo "# $(basename "$(pwd)")" > README.md
      git add README.md
    else
      git add -A
    fi
    git commit -m "Initial commit" >/dev/null
  fi
}

gam_confirm() { local msg="${1:-Proceed?}"; read -r -p "${msg} [y/N] " a || true; [[ "${a}" =~ ^([yY]|[yY][eE][sS])$ ]]; }

# Resolve which account a host alias refers to, using env/config provided vars
# Expected (from config): GAM_PERSONAL_SSH_HOST, GAM_BUSINESS_SSH_HOST
gam_account_from_host() {
  local host="$1"
  case "${host}" in
    "${GAM_PERSONAL_SSH_HOST:-github-personal}") printf 'personal\n';;
    "${GAM_BUSINESS_SSH_HOST:-github-business}") printf 'business\n';;
    *) printf 'unknown\n';;
  esac
}

gam_current_remote_host() {
  local url; url="$(git remote get-url origin 2>/dev/null || true)"
  [[ -z "${url}" ]] && return 1
  case "${url}" in
    git@*:*/*)
      # Extract just the host part between @ and :
      local host="${url#git@}"
      host="${host%%:*}"
      printf '%s\n' "${host}"
      ;;
    ssh://git@*/*)
      # Extract host from ssh://git@host/path
      local host="${url#ssh://git@}"
      host="${host%%/*}"
      printf '%s\n' "${host}"
      ;;
    https://*/*)
      # Extract host from https://host/path
      local host="${url#https://}"
      host="${host%%/*}"
      printf '%s\n' "${host}"
      ;;
    http://*/*)
      # Extract host from http://host/path
      local host="${url#http://}"
      host="${host%%/*}"
      printf '%s\n' "${host}"
      ;;
    *) return 1;;
  esac
}

gam_current_email() { git config --get user.email 2>/dev/null || true; }

gam_require_gh() {
  gam_cmd_exists gh || gam_die "GitHub CLI (gh) is required for this command. Install & login: gh auth login"
}

# Extract owner and repo from the current origin URL. Prints: "OWNER REPO".
gam_extract_owner_repo_from_remote() {
  local url; url="$(git remote get-url origin 2>/dev/null || true)"
  [[ -z "${url}" ]] && return 1
  
  # Remove .git suffix if present
  url="${url%.git}"
  
  local owner repo
  case "${url}" in
    git@*:*/*)
      # git@host:owner/repo format
      local path="${url#*:}"
      owner="${path%%/*}"
      repo="${path#*/}"
      ;;
    ssh://git@*/*)
      # ssh://git@host/owner/repo format
      local path="${url#ssh://git@*/}"
      path="${path#*/}"  # Skip hostname
      owner="${path%%/*}"
      repo="${path#*/}"
      ;;
    https://github.com/*/*|http://github.com/*/*)
      # https://github.com/owner/repo format
      local path="${url#*github.com/}"
      owner="${path%%/*}"
      repo="${path#*/}"
      ;;
    https://*//*|http://*/*)
      # Generic https://host/owner/repo format
      local path="${url#*://}"
      path="${path#*/}"  # Skip hostname
      owner="${path%%/*}"
      repo="${path#*/}"
      ;;
    *) return 1;;
  esac
  
  # Validate extracted values
  [[ -z "${owner}" || -z "${repo}" ]] && return 1
  printf '%s %s\n' "${owner}" "${repo}"
}

# Ensure origin remote uses the correct SSH host alias for the given account.
# Usage: gam_set_remote_host_for_account personal|business [owner] [repo]
gam_set_remote_host_for_account() {
  local account="${1:?account required}"; shift
  local owner="${1:-}" repo="${2:-}"
  if [[ -z "${owner}" || -z "${repo}" ]]; then
    read -r owner repo <<<"$(gam_extract_owner_repo_from_remote || true)"
  fi
  [[ -z "${owner}" || -z "${repo}" ]] && return 1

  local host
  case "${account}" in
    personal) host="${GAM_PERSONAL_SSH_HOST:-github-personal}" ;;
    business) host="${GAM_BUSINESS_SSH_HOST:-github-business}" ;;
    *) return 1 ;;
  esac

  local current; current="$(git remote get-url origin 2>/dev/null || true)"
  local desired="git@${host}:${owner}/${repo}.git"
  [[ "${current}" = "${desired}" ]] && return 0

  if git remote set-url origin "${desired}" 2>/dev/null; then
    gam_log_audit "remote-rewrite account=${account} url=${desired}"
    printf '%s%s Rewrote origin to %s%s\n' "${C_BLUE}" "${SYM_ARROW}" "${desired}" "${C_RESET}"
    return 0
  fi
  return 1
}

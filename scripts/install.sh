#!/usr/bin/env bash
# git-account-manager installer
# POSIX-friendly, Bash-compatible
set -Eeuo pipefail
IFS=$'\n\t'

RC_FILE_OVERRIDE=""
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENTRY="${REPO_ROOT}/bin/git-account-manager.sh"
LEGACY_SYMLINK="$HOME/bin/git-account-manager.sh"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/git-account-manager"
BLOCK_BEGIN="# >>> git-account-manager (BEGIN) >>>"
BLOCK_END="# <<< git-account-manager (END) <<<"

usage() {
  cat <<EOF
Usage: scripts/install.sh [--rc-file <path>] [--yes]

- Detects shell RC file and injects a marked block to source:
    ${ENTRY}
- Creates/updates a compatibility symlink at:
    ${LEGACY_SYMLINK}
- Prints post-install checklist.
EOF
}

confirm() { # confirm "message"
  local msg="${1:-Proceed?}"; read -r -p "${msg} [y/N] " ans || true
  case "${ans:-}" in [yY]|[yY][eE][sS]) return 0;; *) return 1;; esac
}

detect_rc() {
  if [[ -n "${RC_FILE_OVERRIDE}" ]]; then
    printf '%s\n' "${RC_FILE_OVERRIDE}"
    return
  fi
  local shell="${SHELL:-}"
  if [[ "${shell##*/}" == "zsh" ]]; then
    printf '%s\n' "$HOME/.zshrc"
  else
    if [[ -f "$HOME/.bashrc" ]]; then
      printf '%s\n' "$HOME/.bashrc"
    else
      printf '%s\n' "$HOME/.bash_profile"
    fi
  fi
}

already_present() { # already_present <rcfile>
  local rc="$1"
  [[ -f "${rc}" ]] && grep -qF "${BLOCK_BEGIN}" "${rc}"
}

inject_block() { # inject_block <rcfile>
  local rc="$1"
  mkdir -p "$(dirname "${rc}")"
  touch "${rc}"
  if already_present "${rc}"; then
    printf 'Installer: RC block already present in %s (idempotent).\n' "${rc}"
    return
  fi
  {
    printf '\n%s\n' "${BLOCK_BEGIN}"
    printf 'GAM_ROOT=%q\n' "${REPO_ROOT}"
    # shellcheck disable=SC2016  # Variables should expand at runtime, not install time
    printf 'if [ -f "$GAM_ROOT/bin/git-account-manager.sh" ]; then\n'
    printf '  # shellcheck disable=SC1091\n'
    # shellcheck disable=SC2016  # Variables should expand at runtime, not install time
    printf '  . "$GAM_ROOT/bin/git-account-manager.sh"\n'
    printf 'fi\n'
    printf '%s\n' "${BLOCK_END}"
  } >> "${rc}"
  printf 'Installer: Appended sourcing block to %s\n' "${rc}"
}

ensure_legacy_symlink() {
  mkdir -p "$(dirname "${LEGACY_SYMLINK}")"
  if [[ -L "${LEGACY_SYMLINK}" || -e "${LEGACY_SYMLINK}" ]]; then
    rm -f "${LEGACY_SYMLINK}"
  fi
  ln -s "${ENTRY}" "${LEGACY_SYMLINK}"
  printf 'Installer: Created compatibility symlink %s -> %s\n' "${LEGACY_SYMLINK}" "${ENTRY}"
}

post_install() {
  cat <<'EOF'
Post-install checklist (run now):
  type git-help && git-help -h
  git-usage
  git-validate
  git-setup-ssh-hosts
EOF
}

source_rc_now() { # source_rc_now <rcfile>
  local rc="$1"
  # Try to source in this subshell (for immediate availability here)
  # Parent shell won't be affected; offer user to exec a login shell.
  # shellcheck disable=SC1090
  . "${rc}" || true
  printf '\nTo load in your current shell, run: . %q\n' "${rc}"
  if confirm "Optionally restart your shell as a login shell now?"; then
    exec "${SHELL:-/bin/bash}" -l
  fi
}

main() {
  local yes="0"
  while (( "$#" )); do
    case "$1" in
      --rc-file) RC_FILE_OVERRIDE="${2:?}"; shift 2;;
      --yes|-y) yes="1"; shift;;
      -h|--help) usage; exit 0;;
      *) printf 'Unknown option: %s\n' "$1"; usage; exit 1;;
    esac
  done
  mkdir -p "${CONFIG_DIR}"
  local rc; rc="$(detect_rc)"
  printf 'Installer: using RC file %s\n' "${rc}"
  inject_block "${rc}"
  ensure_legacy_symlink
  post_install
  if [[ "${yes}" == "1" ]]; then
    # non-interactive: do not exec shell; just print instructions
    printf '\nNon-interactive mode: open a new terminal or run: . %q\n' "${rc}"
  else
    source_rc_now "${rc}"
  fi
}
main "$@"

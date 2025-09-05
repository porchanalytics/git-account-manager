#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
BLOCK_BEGIN="# >>> git-account-manager (BEGIN) >>>"
BLOCK_END="# <<< git-account-manager (END) <<<"
LEGACY_SYMLINK="$HOME/bin/git-account-manager.sh"

usage() {
  cat <<EOF
Usage: scripts/uninstall.sh [--rc-file <path>]
Removes the sourcing block and deletes the compatibility symlink.
EOF
}

detect_rc() {
  if [[ -n "${1:-}" ]]; then printf '%s\n' "$1"; return; fi
  local shell="${SHELL:-}"
  if [[ "${shell##*/}" == "zsh" ]]; then
    printf '%s\n' "$HOME/.zshrc"
  else
    if [[ -f "$HOME/.bashrc" ]]; then printf '%s\n' "$HOME/.bashrc"; else printf '%s\n' "$HOME/.bash_profile"; fi
  fi
}

strip_block() { # <rcfile>
  local rc="$1"
  [[ -f "${rc}" ]] || { printf 'No RC file at %s\n' "${rc}"; return; }
  awk -v b="${BLOCK_BEGIN}" -v e="${BLOCK_END}" 'BEGIN {skip=0}$0 ~ b {skip=1; next}
    $0 ~ e {skip=0; next}
    skip==0 {print}
  ' "${rc}" > "${rc}.tmp"
  mv "${rc}.tmp" "${rc}"
  printf 'Uninstall: removed sourcing block from %s (if present)\n' "${rc}"
}

remove_symlink() {
  if [[ -L "${LEGACY_SYMLINK}" || -e "${LEGACY_SYMLINK}" ]]; then
    rm -f "${LEGACY_SYMLINK}"
    printf 'Uninstall: removed %s\n' "${LEGACY_SYMLINK}"
  fi
}

main() {
  local rc_override=""
  while (( "$#" )); do
    case "$1" in
      --rc-file) rc_override="${2:?}"; shift 2;;
      -h|--help) usage; exit 0;;
      *) printf 'Unknown option: %s\n' "$1"; usage; exit 1;;
    esac
  done
  local rc; rc="$(detect_rc "${rc_override}")"
  strip_block "${rc}"
  remove_symlink
  printf 'Uninstall complete. Repo directory untouched.\n'
}
main "$@"

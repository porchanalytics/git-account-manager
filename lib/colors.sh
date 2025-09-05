#!/usr/bin/env bash
if ! (return 0 2>/dev/null); then
  set -Eeuo pipefail
  IFS=$'\n\t'
fi

# shellcheck disable=SC2034  # Colors and symbols exported for external use

# Full color palette for enhanced visual experience
if command -v tput >/dev/null 2>&1 && [[ -n "${TERM:-}" ]] && [[ "${TERM}" != "dumb" ]]; then
  # Text formatting (with error handling)
  C_BOLD="$(tput bold 2>/dev/null || echo "")"
  C_DIM="$(tput dim 2>/dev/null || echo "")" 
  C_RESET="$(tput sgr0 2>/dev/null || echo "")"
  
  # Colors (with error handling)
  C_RED="$(tput setaf 1 2>/dev/null || echo "")"
  C_GREEN="$(tput setaf 2 2>/dev/null || echo "")" 
  C_YELLOW="$(tput setaf 3 2>/dev/null || echo "")"
  C_BLUE="$(tput setaf 4 2>/dev/null || echo "")"
  C_MAGENTA="$(tput setaf 5 2>/dev/null || echo "")"
  C_CYAN="$(tput setaf 6 2>/dev/null || echo "")"
  C_WHITE="$(tput setaf 7 2>/dev/null || echo "")"
  
  # Background colors (with error handling)
  C_BG_RED="$(tput setab 1 2>/dev/null || echo "")"
  C_BG_GREEN="$(tput setab 2 2>/dev/null || echo "")"
  C_BG_YELLOW="$(tput setab 3 2>/dev/null || echo "")"
  C_BG_BLUE="$(tput setab 4 2>/dev/null || echo "")"
else
  # Fallback for terminals without tput or dumb terminals
  C_BOLD=""
  C_DIM=""
  C_RESET=""
  C_RED=""
  C_GREEN=""
  C_YELLOW=""
  C_BLUE=""
  C_MAGENTA=""
  C_CYAN=""
  C_WHITE=""
  C_BG_RED=""
  C_BG_GREEN=""
  C_BG_YELLOW=""
  C_BG_BLUE=""
fi

# Box drawing characters for visual formatting
# shellcheck disable=SC2034  # Exported for use in other files
BOX_H="━"
# shellcheck disable=SC2034  # Exported for use in other files
BOX_V="┃"
# shellcheck disable=SC2034  # Exported for use in other files
BOX_TL="┏"
# shellcheck disable=SC2034  # Exported for use in other files
BOX_TR="┓"
# shellcheck disable=SC2034  # Exported for use in other files
BOX_BL="┗"
# shellcheck disable=SC2034  # Exported for use in other files
BOX_BR="┛"
# shellcheck disable=SC2034  # Exported for use in other files
BOX_CROSS="╋"
# shellcheck disable=SC2034  # Exported for use in other files
BOX_T="┳"
# shellcheck disable=SC2034  # Exported for use in other files
BOX_B="┻"
# shellcheck disable=SC2034  # Exported for use in other files
BOX_L="┣"
# shellcheck disable=SC2034  # Exported for use in other files
BOX_R="┫"

# Status symbols
# shellcheck disable=SC2034  # Exported for use in other files
SYM_CHECK="✓"
# shellcheck disable=SC2034  # Exported for use in other files
SYM_CROSS="✗"
# shellcheck disable=SC2034  # Exported for use in other files
SYM_ARROW="→"
# shellcheck disable=SC2034  # Exported for use in other files
SYM_BULLET="•"
# shellcheck disable=SC2034  # Exported for use in other files
SYM_WARNING="⚠"
# shellcheck disable=SC2034  # Exported for use in other files
SYM_INFO="ℹ"


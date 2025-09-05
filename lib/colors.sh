#!/usr/bin/env bash
if ! (return 0 2>/dev/null); then
  set -Eeuo pipefail
  IFS=$'\n\t'
fi

# Full color palette for enhanced visual experience
if command -v tput >/dev/null 2>&1 && [[ -n "${TERM:-}" ]] && [[ "${TERM}" != "dumb" ]]; then
  # Text formatting
  C_BOLD="$(tput bold)"
  C_DIM="$(tput dim)" 
  C_RESET="$(tput sgr0)"
  
  # Colors
  C_RED="$(tput setaf 1)"
  C_GREEN="$(tput setaf 2)" 
  C_YELLOW="$(tput setaf 3)"
  C_BLUE="$(tput setaf 4)"
  C_MAGENTA="$(tput setaf 5)"
  C_CYAN="$(tput setaf 6)"
  C_WHITE="$(tput setaf 7)"
  
  # Background colors (for special emphasis)
  C_BG_RED="$(tput setab 1)"
  C_BG_GREEN="$(tput setab 2)"
  C_BG_YELLOW="$(tput setab 3)"
  C_BG_BLUE="$(tput setab 4)"
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
BOX_H="━"
BOX_V="┃"
BOX_TL="┏"
BOX_TR="┓"
BOX_BL="┗"
BOX_BR="┛"
BOX_CROSS="╋"
BOX_T="┳"
BOX_B="┻"
BOX_L="┣"
BOX_R="┫"

# Status symbols
SYM_CHECK="✓"
SYM_CROSS="✗"
SYM_ARROW="→"
SYM_BULLET="•"
SYM_WARNING="⚠"
SYM_INFO="ℹ"


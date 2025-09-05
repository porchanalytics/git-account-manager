#!/usr/bin/env bash
if ! (return 0 2>/dev/null); then
  set -Eeuo pipefail
  IFS=$'\n\t'
fi

_gam_usage_clone() {
  cat <<'EOF'
Usage: git-clone --account personal|business --owner <OWNER> --repo <REPO> [--target <DIR>]
Example:
  git-clone --account personal --owner octocat --repo hello --target ./hello
EOF
}

git-clone() {
  local account="" owner="" repo="" target=""
  while (( "$#" )); do
    case "$1" in
      --account) account="${2:?}"; shift 2;;
      --owner) owner="${2:?}"; shift 2;;
      --repo) repo="${2:?}"; shift 2;;
      --target) target="${2:?}"; shift 2;;
      -h|--help) _gam_usage_clone; return 0;;
      *) echo "Unknown flag: $1"; _gam_usage_clone; return 1;;
    esac
  done
  [[ -z "${account}" || -z "${owner}" || -z "${repo}" ]] && { _gam_usage_clone; return 1; }
  local host
  case "${account}" in
    personal) host="${GAM_PERSONAL_SSH_HOST:-github-personal}";;
    business) host="${GAM_BUSINESS_SSH_HOST:-github-business}";;
    *) gam_die "Unknown account: ${account}";;
  esac
  
  # Auto-setup SSH host if missing
  if [[ "${GAM_AUTO_FIX:-1}" = "1" ]] && ! grep -qE "^Host[[:space:]]+${host}\b" "$HOME/.ssh/config" 2>/dev/null; then
    printf '%s%s Auto-setting up SSH host aliases...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
    git-setup-ssh-hosts 2>/dev/null || true
  fi
  
  local url="git@${host}:${owner}/${repo}.git"
  local dest="${target:-${repo}}"
  printf 'Running: git clone %q %q\n' "${url}" "${dest}"
  if ! git clone "${url}" "${dest}"; then
    gam_die "Failed to clone repository from ${url}"
  fi
  gam_log_audit "clone account=${account} url=${url} dest=${dest}"
}

_gam_usage_init() {
  cat <<'EOF'
Usage: git-init --account personal|business --repo <REPO>
Initializes and sets origin for the current directory repo.
EOF
}

git-init() {
  local account="" repo=""
  while (( "$#" )); do
    case "$1" in
      --account) account="${2:?}"; shift 2;;
      --repo) repo="${2:?}"; shift 2;;
      -h|--help) _gam_usage_init; return 0;;
      *) echo "Unknown flag: $1"; _gam_usage_init; return 1;;
    esac
  done
  [[ -z "${account}" || -z "${repo}" ]] && { _gam_usage_init; return 1; }
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git init -b main >/dev/null 2>&1; then :; else git init >/dev/null && git checkout -b main >/dev/null; fi
  fi
  local owner="${GAM_${account^^}_GITHUB:-}"
  [[ -z "${owner}" ]] && gam_warn "Owner for ${account} not set in config; pass via git-remote-set later."
  if [[ -n "${owner}" ]]; then
    git-remote-set --account "${account}" --owner "${owner}" --repo "${repo}"
  fi
}

_gam_usage_clone_and_own() {
  cat <<'EOF'
Usage: git-clone-and-own --src <URL|OWNER/REPO> [--new <NEW_REPO>] [--account A] [--visibility public|private]
Clones a public repo and pushes to your own fork/new repo.
EOF
}

git-clone-and-own() {
  # If no args provided, run interactive mode
  if [[ $# -eq 0 ]]; then
    _git_clone_and_own_interactive
    return $?
  fi
  
  # Otherwise handle command line args
  local src="" new="" account="" visibility="private"
  while (( "$#" )); do
    case "$1" in
      --src|--src-slug) src="${2:?}"; shift 2;;
      --new) new="${2:?}"; shift 2;;
      --account) account="${2:?}"; shift 2;;
      --visibility) visibility="${2:?}"; shift 2;;
      -h|--help) _gam_usage_clone_and_own; return 0;;
      *) echo "Unknown flag: $1"; _gam_usage_clone_and_own; return 1;;
    esac
  done
  [[ -z "${src}" ]] && { _gam_usage_clone_and_own; return 1; }
  
  _git_clone_and_own_execute "$src" "$new" "$account" "$visibility"
}

_git_clone_and_own_interactive() {
  printf '%s%sClone and Own - Interactive Mode%s\n' "${C_BOLD}${C_BLUE}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}"
  printf '\nThis will clone a repository and create your own copy.\n\n'
  
  # Get source repository
  local src=""
  while [[ -z "$src" ]]; do
    printf '%s%s Source repository:%s ' "${C_BOLD}" "${SYM_ARROW}" "${C_RESET}"
    read -r src
    if [[ -z "$src" ]]; then
      printf '%s%s Please enter a repository (e.g., owner/repo or full URL)%s\n' "${C_YELLOW}" "${SYM_WARNING}" "${C_RESET}"
    fi
  done
  
  # Parse and validate
  local owner repo
  if ! read -r owner repo <<<"$(gam_parse_repo_arg "${src}" 2>/dev/null)"; then
    gam_die "Invalid repository format: ${src}"
  fi
  
  # Get new repository name
  printf '%s%s New repository name:%s [%s%s%s] ' "${C_BOLD}" "${SYM_ARROW}" "${C_RESET}" "${C_DIM}" "${repo}" "${C_RESET}"
  local new=""
  read -r new
  new="${new:-${repo}}"
  
  # Get account
  printf '%s%s Target account:%s\n' "${C_BOLD}" "${SYM_ARROW}" "${C_RESET}"
  printf '  1) %sPersonal%s (%s)\n' "${C_GREEN}" "${C_RESET}" "${GAM_PERSONAL_GITHUB:-personal}"
  printf '  2) %sBusiness%s (%s)\n' "${C_BLUE}" "${C_RESET}" "${GAM_BUSINESS_GITHUB:-business}"
  printf 'Choice [1]: '
  local choice=""
  read -r choice
  choice="${choice:-1}"
  
  local account=""
  case "$choice" in
    1) account="personal" ;;
    2) account="business" ;;
    *) gam_die "Invalid choice: ${choice}" ;;
  esac
  
  # Get visibility
  printf '%s%s Repository visibility:%s\n' "${C_BOLD}" "${SYM_ARROW}" "${C_RESET}"
  printf '  1) %sPrivate%s (recommended)\n' "${C_YELLOW}" "${C_RESET}"
  printf '  2) %sPublic%s\n' "${C_GREEN}" "${C_RESET}"
  printf 'Choice [1]: '
  local vis_choice=""
  read -r vis_choice
  vis_choice="${vis_choice:-1}"
  
  local visibility=""
  case "$vis_choice" in
    1) visibility="private" ;;
    2) visibility="public" ;;
    *) gam_die "Invalid choice: ${vis_choice}" ;;
  esac
  
  # Show summary
  printf '\n%s%sSummary:%s\n' "${C_BOLD}${C_MAGENTA}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}"
  printf '%s Source: %s%s/%s%s\n' "${SYM_BULLET}" "${C_DIM}" "$owner" "$repo" "${C_RESET}"
  printf '%s New repo: %s%s%s\n' "${SYM_BULLET}" "${C_BOLD}" "$new" "${C_RESET}"
  printf '%s Account: %s%s%s\n' "${SYM_BULLET}" "$([[ "$account" == "personal" ]] && echo "${C_GREEN}" || echo "${C_BLUE}")" "$account" "${C_RESET}"
  printf '%s Visibility: %s%s%s\n' "${SYM_BULLET}" "$([[ "$visibility" == "private" ]] && echo "${C_YELLOW}" || echo "${C_GREEN}")" "$visibility" "${C_RESET}"
  printf '\n'
  
  # Confirm
  if ! gam_confirm "Proceed with clone and own?"; then
    printf '%s%s Operation cancelled%s\n' "${C_YELLOW}" "${SYM_INFO}" "${C_RESET}"
    return 0
  fi
  
  _git_clone_and_own_execute "$src" "$new" "$account" "$visibility"
}

_git_clone_and_own_execute() {
  local src="$1" new="$2" account="${3:-personal}" visibility="${4:-private}"
  
  read -r owner repo <<<"$(gam_parse_repo_arg "${src}")"
  local dst_repo="${new:-${repo}}"
  
  printf '\n%s%s Cloning source repository...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
  git clone "https://github.com/${owner}/${repo}.git" "${dst_repo}"
  
  ( cd "${dst_repo}"
    printf '%s%s Setting up new repository...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
    
    # Remove original remote
    git remote remove origin 2>/dev/null || true
    
    # Set local git config for chosen account
    case "$account" in
      personal) use-personal ;;
      business) use-business ;;
    esac
    
    # Create new repo (try multiple methods)
    local success=0
    
    # Method 1: GitHub CLI
    if gam_cmd_exists gh && gh auth status >/dev/null 2>&1; then
      printf '%s%s Creating GitHub repository via CLI...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
      local gh_visibility="--private"; [[ "${visibility}" = "public" ]] && gh_visibility="--public"
      
      if [[ "${GAM_SKIP_PUSH:-0}" = "1" ]]; then
        gh repo create "${dst_repo}" ${gh_visibility} --source . --remote origin 2>/dev/null && success=1
      else
        gh repo create "${dst_repo}" ${gh_visibility} --source . --remote origin --push 2>/dev/null && success=1
      fi
    fi
    
    # Method 2: Manual fallback
    if [[ $success -eq 0 ]]; then
      printf '%s%s GitHub CLI not available or failed%s\n' "${C_YELLOW}" "${SYM_WARNING}" "${C_RESET}"
      printf '%s%s Manual setup required:%s\n' "${C_BOLD}${C_YELLOW}" "${SYM_INFO}" "${C_RESET}"
      printf '  1. Go to GitHub and create new repository: %s%s%s\n' "${C_BOLD}" "${dst_repo}" "${C_RESET}"
      printf '  2. Make it %s%s%s\n' "${C_BOLD}" "${visibility}" "${C_RESET}"
      printf '  3. Press Enter when ready to continue...\n'
      read -r
      
      # Set up remote manually
      local target_owner=""
      case "$account" in
        personal) target_owner="${GAM_PERSONAL_GITHUB:-}" ;;
        business) target_owner="${GAM_BUSINESS_GITHUB:-}" ;;
      esac
      
      if [[ -n "$target_owner" ]]; then
        git-remote-set --account "$account" --owner "$target_owner" --repo "$dst_repo"
        
        if [[ "${GAM_SKIP_PUSH:-0}" != "1" ]]; then
          printf '%s%s Pushing to new repository...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
          git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null || true
        fi
      fi
    fi
    
    gam_log_audit "clone-and-own src=${owner}/${repo} new=${dst_repo} vis=${visibility} acct=${account}"
  )
  
  printf '\n%s%s %sClone and own completed!%s\n' "${C_GREEN}" "${SYM_CHECK}" "${C_BOLD}" "${C_RESET}"
  printf '%s%s New repository: %s%s%s\n' "${C_GREEN}" "${SYM_ARROW}" "${C_BOLD}" "${dst_repo}" "${C_RESET}"
}

_gam_usage_bootstrap() {
  cat <<'EOF'
Usage: git-bootstrap-here --repo <NAME> [--visibility public|private] [--owner <OWNER>] [--no-push]
Initializes this folder, creates the first commit if needed,
creates a GitHub repo via 'gh repo create --source . --remote origin [--private|--public] [--push]',
and prints the remote URL and summary.
EOF
}

git-bootstrap-here() {
  local repo="" visibility="private" owner="" nopush="0"
  while (( "$#" )); do
    case "$1" in
      --repo) repo="${2:?}"; shift 2;;
      --visibility) visibility="${2:?}"; shift 2;;
      --owner) owner="${2:?}"; shift 2;;
      --no-push) nopush="1"; shift;;
      -h|--help) _gam_usage_bootstrap; return 0;;
      *) echo "Unknown flag: $1"; _gam_usage_bootstrap; return 1;;
    esac
  done
  [[ -z "${repo}" ]] && { _gam_usage_bootstrap; return 1; }
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git init -b main >/dev/null 2>&1; then :; else git init >/dev/null && git checkout -b main >/dev/null; fi
  fi
  gam_git_add_initial_commit_if_needed

  gam_require_gh
  local gh_visibility="--private"; [[ "${visibility}" = "public" ]] && gh_visibility="--public"
  local extra=()
  [[ -n "${owner}" ]] && extra+=("${owner}/${repo}") || extra+=("${repo}")
  printf 'Running: gh repo create %s %s --source . --remote origin %s\n' "${extra[*]}" "${gh_visibility}" "$([[ "${nopush}" = "1" ]] && echo "" || echo "--push")"
  if [[ "${nopush}" = "1" || "${GAM_SKIP_PUSH:-0}" = "1" ]]; then
    gh repo create "${extra[@]}" ${gh_visibility} --source . --remote origin >/dev/null
  else
    gh repo create "${extra[@]}" ${gh_visibility} --source . --remote origin --push >/dev/null
  fi
  local url; url="$(git remote get-url origin)"
  printf 'Created and connected:\n  %s\n' "${url}"
  gam_log_audit "bootstrap-here repo=${repo} vis=${visibility} url=${url}"
}


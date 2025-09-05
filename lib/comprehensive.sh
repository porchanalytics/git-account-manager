#!/usr/bin/env bash
if ! (return 0 2>/dev/null); then
  set -Eeuo pipefail
  IFS=$'\n\t'
fi

# Additional comprehensive functions for git account manager

# git-whoami: Show current configuration with color coding  
git-whoami() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-whoami - Show current git configuration"; return 0; }
  
  local in_git_repo=0
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    in_git_repo=1
  fi
  
  printf '%s%sGit Identity Status%s\n' "${C_BOLD}${C_BLUE}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}"
  
  # Local config (if in git repo)
  if [[ $in_git_repo -eq 1 ]]; then
    local local_name="$(git config --get user.name 2>/dev/null || echo "Not set")"
    local local_email="$(git config --get user.email 2>/dev/null || echo "Not set")"
    
    # Determine account type based on email
    local account_type="unknown"
    if [[ "$local_email" == "${GAM_PERSONAL_EMAIL:-}" ]]; then
      account_type="${C_GREEN}personal${C_RESET}"
    elif [[ "$local_email" == "${GAM_BUSINESS_EMAIL:-}" ]]; then
      account_type="${C_BLUE}business${C_RESET}"
    else
      account_type="${C_YELLOW}unknown${C_RESET}"
    fi
    
    printf '%s Local (repo): %s%s <%s>%s [%s]\n' "${SYM_ARROW}" "${C_BOLD}" "$local_name" "$local_email" "${C_RESET}" "$account_type"
    
    # Show remote info if available
    local url; url="$(git remote get-url origin 2>/dev/null || true)"
    if [[ -n "${url}" ]]; then
      local host; host="$(gam_current_remote_host || echo "unknown")"
      local remote_account; remote_account="$(gam_account_from_host "${host}")"
      printf '%s Remote: %s%s%s [%s]\n' "${SYM_ARROW}" "${C_DIM}" "$url" "${C_RESET}" "$remote_account"
    fi
  else
    printf '%s %sNot in a git repository%s\n' "${SYM_INFO}" "${C_DIM}" "${C_RESET}"
  fi
  
  # Global config
  local global_name="$(git config --global --get user.name 2>/dev/null || echo "Not set")"
  local global_email="$(git config --global --get user.email 2>/dev/null || echo "Not set")"
  
  local global_account_type="unknown"
  if [[ "$global_email" == "${GAM_PERSONAL_EMAIL:-}" ]]; then
    global_account_type="${C_GREEN}personal${C_RESET}"
  elif [[ "$global_email" == "${GAM_BUSINESS_EMAIL:-}" ]]; then
    global_account_type="${C_BLUE}business${C_RESET}"
  else
    global_account_type="${C_YELLOW}unknown${C_RESET}"
  fi
  
  printf '%s Global: %s%s <%s>%s [%s]\n' "${SYM_ARROW}" "${C_BOLD}" "$global_name" "$global_email" "${C_RESET}" "$global_account_type"
}

# git-personal-global / git-business-global: Switch global config
git-personal-global() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-personal-global - Set global git config to personal account"; return 0; }
  local name="${GAM_PERSONAL_NAME:-Personal User}"
  local email="${GAM_PERSONAL_EMAIL:-[email protected]}"
  git config --global user.name "${name}"
  git config --global user.email "${email}"
  gam_log_audit "personal-global email=${email}"
  printf '%s%s %sSet global config to personal: %s <%s>%s\n' "${C_GREEN}" "${SYM_CHECK}" "${C_RESET}${C_BOLD}" "${name}" "${email}" "${C_RESET}"
}

git-business-global() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-business-global - Set global git config to business account"; return 0; }
  local name="${GAM_BUSINESS_NAME:-Business User}"  
  local email="${GAM_BUSINESS_EMAIL:-[email protected]}"
  git config --global user.name "${name}"
  git config --global user.email "${email}"
  gam_log_audit "business-global email=${email}"
  printf '%s%s %sSet global config to business: %s <%s>%s\n' "${C_BLUE}" "${SYM_CHECK}" "${C_RESET}${C_BOLD}" "${name}" "${email}" "${C_RESET}"
}

# git-personal / git-business: Aliases for local config (to match requirements)
git-personal() { use-personal "$@"; }
git-business() { use-business "$@"; }

# git-remote-personal / git-remote-business: Switch remotes (enhanced)
git-remote-personal() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-remote-personal <REPO> - Set origin to personal account repo"; return 0; }
  local repo="${1:?Repository name required}"
  local owner="${GAM_PERSONAL_GITHUB:-}"
  [[ -z "$owner" ]] && gam_die "GAM_PERSONAL_GITHUB not set in config"
  git-remote-set --account personal --owner "$owner" --repo "$repo"
}

git-remote-business() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-remote-business <REPO> - Set origin to business account repo"; return 0; }  
  local repo="${1:?Repository name required}"
  local owner="${GAM_BUSINESS_GITHUB:-}"
  [[ -z "$owner" ]] && gam_die "GAM_BUSINESS_GITHUB not set in config"
  git-remote-set --account business --owner "$owner" --repo "$repo"
}

# git-remote-info: Display remotes with account indicators
git-remote-info() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-remote-info - Show remote URLs with account indicators"; return 0; }
  
  gam_require_git_repo
  
  printf '%s%sRemote Information%s\n' "${C_BOLD}${C_MAGENTA}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}"
  
  # Get all remotes
  local remotes; remotes="$(git remote 2>/dev/null || true)"
  if [[ -z "$remotes" ]]; then
    printf '%s %sNo remotes configured%s\n' "${SYM_INFO}" "${C_DIM}" "${C_RESET}"
    return 0
  fi
  
  while IFS= read -r remote; do
    local url; url="$(git remote get-url "$remote" 2>/dev/null || echo "unknown")"
    local host; host="$(echo "$url" | sed -E 's|^git@([^:]+):.*|\1|' || echo "unknown")" 
    local account; account="$(gam_account_from_host "$host")"
    
    local color="${C_RESET}"
    case "$account" in
      personal) color="${C_GREEN}" ;;
      business) color="${C_BLUE}" ;;
      *) color="${C_YELLOW}" ;;
    esac
    
    printf '%s %s%s%s: %s%s%s [%s%s%s]\n' "${SYM_ARROW}" "${C_BOLD}" "$remote" "${C_RESET}" "${C_DIM}" "$url" "${C_RESET}" "$color" "$account" "${C_RESET}"
  done <<< "$remotes"
}

# git-test-ssh: Test both SSH connections  
git-test-ssh() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-test-ssh - Test SSH connections to both accounts"; return 0; }
  
  printf '%s%sSSH Connection Test%s\n' "${C_BOLD}${C_CYAN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}"
  
  local personal_host="${GAM_PERSONAL_SSH_HOST:-github-personal}"
  local business_host="${GAM_BUSINESS_SSH_HOST:-github-business}"
  
  # Test personal
  printf '%s Testing personal account (%s%s%s)... ' "${SYM_ARROW}" "${C_GREEN}" "$personal_host" "${C_RESET}"
  if ssh -T "git@$personal_host" 2>&1 | grep -q "successfully authenticated"; then
    printf '%s%s %sSuccess%s\n' "${C_GREEN}" "${SYM_CHECK}" "${C_BOLD}" "${C_RESET}"
  else
    printf '%s%s %sFailed%s\n' "${C_RED}" "${SYM_CROSS}" "${C_BOLD}" "${C_RESET}"
  fi
  
  # Test business  
  printf '%s Testing business account (%s%s%s)... ' "${SYM_ARROW}" "${C_BLUE}" "$business_host" "${C_RESET}"
  if ssh -T "git@$business_host" 2>&1 | grep -q "successfully authenticated"; then
    printf '%s%s %sSuccess%s\n' "${C_GREEN}" "${SYM_CHECK}" "${C_BOLD}" "${C_RESET}"
  else
    printf '%s%s %sFailed%s\n' "${C_RED}" "${SYM_CROSS}" "${C_BOLD}" "${C_RESET}"
  fi
}

# git-list-ssh-keys: Show loaded keys with account labels
git-list-ssh-keys() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-list-ssh-keys - List SSH keys loaded in ssh-agent"; return 0; }
  
  printf '%s%sLoaded SSH Keys%s\n' "${C_BOLD}${C_CYAN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}"
  
  if ! gam_cmd_exists ssh-add; then
    printf '%s %sssh-add not available%s\n' "${SYM_INFO}" "${C_DIM}" "${C_RESET}"
    return 0
  fi
  
  local keys; keys="$(ssh-add -l 2>/dev/null || true)"
  if [[ -z "$keys" || "$keys" == "The agent has no identities." ]]; then
    printf '%s %sNo keys loaded in ssh-agent%s\n' "${SYM_INFO}" "${C_DIM}" "${C_RESET}"
    return 0
  fi
  
  local personal_key="${GAM_PERSONAL_SSH_KEY:-}"
  local business_key="${GAM_BUSINESS_SSH_KEY:-}"
  
  while IFS= read -r line; do
    local fingerprint="${line%% *}"
    local key_path="${line##* }"
    local account_label=""
    
    if [[ -n "$personal_key" && "$key_path" == *"$(basename "$personal_key")"* ]]; then
      account_label=" ${C_GREEN}[personal]${C_RESET}"
    elif [[ -n "$business_key" && "$key_path" == *"$(basename "$business_key")"* ]]; then  
      account_label=" ${C_BLUE}[business]${C_RESET}"
    fi
    
    printf '%s %s%s%s%s\n' "${SYM_ARROW}" "${C_DIM}" "$line" "${C_RESET}" "$account_label"
  done <<< "$keys"
}

# git-clone-personal / git-clone-business: Clone existing repos
git-clone-personal() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-clone-personal <owner/repo> [target] - Clone repo using personal account"; return 0; }
  local repo_arg="${1:?Repository required (format: owner/repo)}"
  local target="${2:-}"
  
  # Auto-switch to personal identity before cloning
  if [[ "${GAM_AUTO_FIX:-1}" = "1" ]]; then
    printf '%s%s Auto-switching to personal account...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
    use-personal
  fi
  
  read -r owner repo <<<"$(gam_parse_repo_arg "${repo_arg}")"
  local args=(--account personal --owner "$owner" --repo "$repo")
  [[ -n "$target" ]] && args+=(--target "$target")
  git-clone "${args[@]}"
  
  # Set identity in the cloned repo
  if [[ "${GAM_AUTO_FIX:-1}" = "1" ]] && [[ -d "${target:-${repo}}" ]]; then
    (cd "${target:-${repo}}" && use-personal)
  fi
}

git-clone-business() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-clone-business <owner/repo> [target] - Clone repo using business account"; return 0; }
  local repo_arg="${1:?Repository required (format: owner/repo)}"  
  local target="${2:-}"
  
  # Auto-switch to business identity before cloning
  if [[ "${GAM_AUTO_FIX:-1}" = "1" ]]; then
    printf '%s%s Auto-switching to business account...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
    use-business
  fi
  
  read -r owner repo <<<"$(gam_parse_repo_arg "${repo_arg}")"
  local args=(--account business --owner "$owner" --repo "$repo")
  [[ -n "$target" ]] && args+=(--target "$target")
  git-clone "${args[@]}"
  
  # Set identity in the cloned repo
  if [[ "${GAM_AUTO_FIX:-1}" = "1" ]] && [[ -d "${target:-${repo}}" ]]; then
    (cd "${target:-${repo}}" && use-business)
  fi
}

# git-init-personal / git-init-business: Initialize new repos  
git-init-personal() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-init-personal <repo> - Initialize repo for personal account"; return 0; }
  local repo="${1:?Repository name required}"
  git-init --account personal --repo "$repo"
  use-personal  # Set local identity
}

git-init-business() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-init-business <repo> - Initialize repo for business account"; return 0; }
  local repo="${1:?Repository name required}"  
  git-init --account business --repo "$repo"
  use-business  # Set local identity
}

# git-token-setup: Guide for setting up PATs
git-token-setup() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-token-setup - Guide for setting up GitHub Personal Access Tokens"; return 0; }
  
  printf '%s%sGitHub Personal Access Token Setup%s\n' "${C_BOLD}${C_MAGENTA}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}"
  printf '\n'
  
  printf '%s%s Step 1:%s Go to GitHub Settings\n' "${C_BOLD}${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
  printf '   %shttps://github.com/settings/tokens%s\n' "${C_CYAN}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s Step 2:%s Create tokens for each account\n' "${C_BOLD}${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
  printf '   %s%s Personal:%s Generate token with repo permissions\n' "${SYM_BULLET}" "${C_GREEN}" "${C_RESET}"
  printf '   %s%s Business:%s Generate token with repo permissions\n' "${SYM_BULLET}" "${C_BLUE}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s Step 3:%s Set environment variables\n' "${C_BOLD}${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
  printf '   %sexport GITHUB_PERSONAL_TOKEN="ghp_xxxxx"%s\n' "${C_DIM}" "${C_RESET}"
  printf '   %sexport GITHUB_BUSINESS_TOKEN="ghp_xxxxx"%s\n' "${C_DIM}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s Current Status:%s\n' "${C_BOLD}${C_YELLOW}" "${SYM_INFO}" "${C_RESET}"
  if [[ -n "${GITHUB_PERSONAL_TOKEN:-}" ]]; then
    printf '   %s%s Personal token: Set%s\n' "${C_GREEN}" "${SYM_CHECK}" "${C_RESET}"
  else
    printf '   %s%s Personal token: Not set%s\n' "${C_YELLOW}" "${SYM_CROSS}" "${C_RESET}"
  fi
  
  if [[ -n "${GITHUB_BUSINESS_TOKEN:-}" ]]; then  
    printf '   %s%s Business token: Set%s\n' "${C_GREEN}" "${SYM_CHECK}" "${C_RESET}"
  else
    printf '   %s%s Business token: Not set%s\n' "${C_YELLOW}" "${SYM_CROSS}" "${C_RESET}" 
  fi
}

# git-gh-setup: Guide for gh CLI setup
git-gh-setup() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-gh-setup - Guide for setting up GitHub CLI"; return 0; }
  
  printf '%s%sGitHub CLI Setup%s\n' "${C_BOLD}${C_MAGENTA}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}"
  printf '\n'
  
  if gam_cmd_exists gh; then
    printf '%s%s GitHub CLI is installed%s\n' "${C_GREEN}" "${SYM_CHECK}" "${C_RESET}"
    
    # Check auth status
    if gh auth status >/dev/null 2>&1; then
      local user; user="$(gh api user --jq .login 2>/dev/null || echo "unknown")"
      printf '%s%s Authenticated as: %s%s%s\n' "${C_GREEN}" "${SYM_CHECK}" "${C_BOLD}" "$user" "${C_RESET}"
    else
      printf '%s%s Not authenticated%s\n' "${C_YELLOW}" "${SYM_CROSS}" "${C_RESET}"
      printf '\n%s%s Next step:%s Run %sgh auth login%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}" "${C_BOLD}" "${C_RESET}"
    fi
  else
    printf '%s%s GitHub CLI not installed%s\n' "${C_RED}" "${SYM_CROSS}" "${C_RESET}"
    printf '\n%s%s Install:%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
    printf '   %smacOS: brew install gh%s\n' "${C_DIM}" "${C_RESET}"
    printf '   %sLinux: See https://cli.github.com%s\n' "${C_DIM}" "${C_RESET}"
  fi
}

# Direct clone-and-own command variants for personal and business
git-clone-as-personal() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-clone-as-personal <url> <name> [public|private] - Clone repo and create personal copy"; return 0; }
  local url="${1:?Source repository URL required}"
  local name="${2:?New repository name required}"
  local visibility="${3:-private}"
  git-clone-and-own --src "$url" --new "$name" --account personal --visibility "$visibility"
}

git-clone-as-business() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-clone-as-business <url> <name> [public|private] - Clone repo and create business copy"; return 0; }
  local url="${1:?Source repository URL required}"
  local name="${2:?New repository name required}"
  local visibility="${3:-private}"
  git-clone-and-own --src "$url" --new "$name" --account business --visibility "$visibility"
}
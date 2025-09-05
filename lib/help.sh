#!/usr/bin/env bash
if ! (return 0 2>/dev/null); then
  set -Eeuo pipefail
  IFS=$'\n\t'
fi

git-help() {
  local topic="${1:-}"
  case "$topic" in
    examples) _git_help_examples ;;
    clone-own) _git_help_clone_own ;;
    workflows) _git_help_workflows ;;
    setup) _git_help_setup ;;
    troubleshoot) _git_help_troubleshoot ;;
    *) _git_help_main ;;
  esac
}

git-usage() { git-help examples; }

_git_help_main() {
  printf '%s%s%sGit Account Manager%s%s\n' "${BOX_TL}" "${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H} " "${C_BOLD}${C_BLUE}" "${C_RESET} ${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}" "${BOX_TR}"
  printf '%s                                           %s\n' "${BOX_V}" "${BOX_V}"
  printf '%s %sManage multiple GitHub accounts easily%s  %s\n' "${BOX_V}" "${C_DIM}" "${C_RESET}" "${BOX_V}"
  printf '%s%s%s\n' "${BOX_BL}" "${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}${BOX_H}" "${BOX_BR}"
  printf '\n'
  
  # Current status section
  printf '%s%s%s Current Status%s\n' "${C_BOLD}${C_CYAN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  _git_help_show_status
  printf '\n'
  
  # Help topics section  
  printf '%s%s%s Help Topics%s\n' "${C_BOLD}${C_MAGENTA}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sgit-help examples%s     - Common usage examples\n' "${SYM_ARROW}" "${C_GREEN}" "${C_RESET}"
  printf '%s %sgit-help clone-own%s    - Clone and own guide\n' "${SYM_ARROW}" "${C_GREEN}" "${C_RESET}"
  printf '%s %sgit-help workflows%s    - Complete workflow scenarios\n' "${SYM_ARROW}" "${C_GREEN}" "${C_RESET}"
  printf '%s %sgit-help setup%s        - Initial setup guide\n' "${SYM_ARROW}" "${C_GREEN}" "${C_RESET}"
  printf '%s %sgit-help troubleshoot%s - Problem-solving guide\n' "${SYM_ARROW}" "${C_GREEN}" "${C_RESET}"
  printf '\n'
  
  # Core commands section
  printf '%s%s%s Core Commands%s\n' "${C_BOLD}${C_BLUE}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sgit-help%s, %sgit-usage%s, %sgit-doctor%s, %sgit-validate%s\n' "${SYM_BULLET}" "${C_CYAN}" "${C_RESET}" "${C_CYAN}" "${C_RESET}" "${C_CYAN}" "${C_RESET}" "${C_CYAN}" "${C_RESET}"
  printf '%s %sgit-install-guard-hook%s [--global]\n' "${SYM_BULLET}" "${C_CYAN}" "${C_RESET}"
  printf '\n'
  
  # Account management section
  printf '%s%s%s Identity & Account Management%s\n' "${C_BOLD}${C_GREEN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %suse-personal%s, %suse-business%s - Switch local repo identity\n' "${SYM_BULLET}" "${C_GREEN}" "${C_RESET}" "${C_BLUE}" "${C_RESET}"
  printf '%s %sgit-personal-global%s, %sgit-business-global%s - Switch global identity\n' "${SYM_BULLET}" "${C_GREEN}" "${C_RESET}" "${C_BLUE}" "${C_RESET}"
  printf '%s %sgit-whoami%s - Show current configuration\n' "${SYM_BULLET}" "${C_CYAN}" "${C_RESET}"
  printf '\n'
  
  # Repository management section
  printf '%s%s%s Repository Management%s\n' "${C_BOLD}${C_YELLOW}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sgit-clone-and-own%s - Interactive clone and create new repo\n' "${SYM_BULLET}" "${C_MAGENTA}" "${C_RESET}"
  printf '%s %sgit-clone-as-personal%s, %sgit-clone-as-business%s - Direct clone variants\n' "${SYM_BULLET}" "${C_GREEN}" "${C_RESET}" "${C_BLUE}" "${C_RESET}"
  printf '%s %sgit-clone-personal%s, %sgit-clone-business%s - Clone existing repos\n' "${SYM_BULLET}" "${C_GREEN}" "${C_RESET}" "${C_BLUE}" "${C_RESET}"
  printf '%s %sgit-init-personal%s, %sgit-init-business%s - Initialize new repos\n' "${SYM_BULLET}" "${C_GREEN}" "${C_RESET}" "${C_BLUE}" "${C_RESET}"
  printf '%s %sgit-bootstrap-here%s - Create repo from current folder\n' "${SYM_BULLET}" "${C_CYAN}" "${C_RESET}"
  printf '\n'
  
  # Remote management section
  printf '%s%s%s Remote Management%s\n' "${C_BOLD}${C_YELLOW}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sgit-remote-set%s - Set remote with account/owner/repo\n' "${SYM_BULLET}" "${C_CYAN}" "${C_RESET}"
  printf '%s %sgit-remote-personal%s, %sgit-remote-business%s - Switch remotes\n' "${SYM_BULLET}" "${C_GREEN}" "${C_RESET}" "${C_BLUE}" "${C_RESET}"
  printf '%s %sgit-remote-info%s - Show remotes with account indicators\n' "${SYM_BULLET}" "${C_CYAN}" "${C_RESET}"
  printf '\n'
  
  # SSH and diagnostics section
  printf '%s%s%s SSH & Diagnostics%s\n' "${C_BOLD}${C_RED}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sgit-setup-ssh-hosts%s - Configure SSH host aliases\n' "${SYM_BULLET}" "${C_CYAN}" "${C_RESET}"
  printf '%s %sgit-test-ssh%s - Test SSH connections\n' "${SYM_BULLET}" "${C_CYAN}" "${C_RESET}"
  printf '%s %sgit-list-ssh-keys%s - Show loaded SSH keys\n' "${SYM_BULLET}" "${C_CYAN}" "${C_RESET}"
  printf '%s %sgit-token-setup%s, %sgit-gh-setup%s - Setup guides\n' "${SYM_BULLET}" "${C_CYAN}" "${C_RESET}" "${C_CYAN}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s All commands support -h|--help%s\n' "${C_DIM}" "${SYM_INFO}" "${C_RESET}"
}

_git_help_show_status() {
  # Check if in git repo and show identity
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local email; email="$(gam_current_email)"
    local account_type="unknown"
    local color="${C_YELLOW}"
    
    if [[ "$email" == "${GAM_PERSONAL_EMAIL:-}" ]]; then
      account_type="personal"
      color="${C_GREEN}"
    elif [[ "$email" == "${GAM_BUSINESS_EMAIL:-}" ]]; then
      account_type="business"  
      color="${C_BLUE}"
    fi
    
    printf '%s Current repo identity: %s%s%s (%s%s%s)\n' "${SYM_ARROW}" "${C_BOLD}" "$email" "${C_RESET}" "$color" "$account_type" "${C_RESET}"
    
    # Show remote if available
    local url; url="$(git remote get-url origin 2>/dev/null || true)"
    if [[ -n "$url" ]]; then
      local host; host="$(gam_current_remote_host || echo "unknown")"
      local remote_account; remote_account="$(gam_account_from_host "$host")"
      printf '%s Current remote: %s%s%s (%s)\n' "${SYM_ARROW}" "${C_DIM}" "$url" "${C_RESET}" "$remote_account"
    fi
  else
    printf '%s %sNot in a git repository%s\n' "${SYM_INFO}" "${C_DIM}" "${C_RESET}"
  fi
  
  # Show GitHub CLI status
  if gam_cmd_exists gh; then
    if gh auth status >/dev/null 2>&1; then
      local user; user="$(gh api user --jq .login 2>/dev/null || echo "unknown")" 
      printf '%s GitHub CLI: %s%s Authenticated as %s%s\n' "${SYM_ARROW}" "${C_GREEN}" "${SYM_CHECK}" "$user" "${C_RESET}"
    else
      printf '%s GitHub CLI: %s%s Not authenticated%s\n' "${SYM_ARROW}" "${C_YELLOW}" "${SYM_CROSS}" "${C_RESET}"
    fi
  else
    printf '%s GitHub CLI: %s%s Not installed%s\n' "${SYM_ARROW}" "${C_RED}" "${SYM_CROSS}" "${C_RESET}"
  fi
  
  # Show token status
  local personal_token_status="${C_RED}${SYM_CROSS}${C_RESET}"
  local business_token_status="${C_RED}${SYM_CROSS}${C_RESET}"
  
  [[ -n "${GITHUB_PERSONAL_TOKEN:-}" ]] && personal_token_status="${C_GREEN}${SYM_CHECK}${C_RESET}"
  [[ -n "${GITHUB_BUSINESS_TOKEN:-}" ]] && business_token_status="${C_GREEN}${SYM_CHECK}${C_RESET}"
  
  printf '%s Tokens: Personal %s Business %s\n' "${SYM_ARROW}" "$personal_token_status" "$business_token_status"
}

_git_help_examples() {
  printf '%s%s%s Common Usage Examples%s\n' "${C_BOLD}${C_GREEN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s Switch Identity%s\n' "${C_BOLD}${C_BLUE}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Switch to personal account (local repo only):\n' "${SYM_BULLET}"
  printf '  %suse-personal%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '%s Switch to business account globally:\n' "${SYM_BULLET}"
  printf '  %sgit-business-global%s\n' "${C_BLUE}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '%s Check current identity:\n' "${SYM_BULLET}"
  printf '  %sgit-whoami%s\n' "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s Repository Operations%s\n' "${C_BOLD}${C_MAGENTA}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Clone and create your own copy (interactive):\n' "${SYM_BULLET}"
  printf '  %sgit-clone-and-own%s\n' "${C_MAGENTA}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '%s Clone and own directly to personal account:\n' "${SYM_BULLET}" 
  printf '  %sgit-clone-as-personal octocat/Hello-World my-hello-world private%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '%s Create repository from current folder:\n' "${SYM_BULLET}"
  printf '  %sgit-bootstrap-here --repo my-project --visibility private%s\n' "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '%s Clone existing personal repository:\n' "${SYM_BULLET}"
  printf '  %sgit-clone-personal dckallos/my-repo%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s Remote Management%s\n' "${C_BOLD}${C_YELLOW}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Retarget existing repo to business account:\n' "${SYM_BULLET}"
  printf '  %sgit-remote-set --account business --owner porchanalytics --repo my-project%s\n' "${C_BLUE}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '%s Quick remote switch to personal:\n' "${SYM_BULLET}"
  printf '  %sgit-remote-personal my-repo%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '%s Show remote information:\n' "${SYM_BULLET}"
  printf '  %sgit-remote-info%s\n' "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s DBT Analytics Use Case%s\n' "${C_BOLD}${C_RED}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Clone DBT package, customize, and publish:\n' "${SYM_BULLET}"
  printf '  %s1. git-clone-and-own  # Interactive mode%s\n' "${C_DIM}" "${C_RESET}"
  printf '  %s2. Choose source: dbt-labs/dbt-utils%s\n' "${C_DIM}" "${C_RESET}"
  printf '  %s3. New name: porch-dbt-utils%s\n' "${C_DIM}" "${C_RESET}"
  printf '  %s4. Account: Business%s\n' "${C_DIM}" "${C_RESET}"
  printf '  %s5. Customize code and push changes%s\n' "${C_DIM}" "${C_RESET}"
}

_git_help_clone_own() {
  printf '%s%s%s Clone and Own Detailed Guide%s\n' "${C_BOLD}${C_MAGENTA}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s What is Clone and Own?%s\n' "${C_BOLD}${C_BLUE}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf 'Clone and Own creates an independent copy of an existing repository\n'
  printf 'under your GitHub account. Perfect for:\n'
  printf '%s Forking open source projects for customization\n' "${SYM_BULLET}"
  printf '%s Creating templates from existing code\n' "${SYM_BULLET}"
  printf '%s Taking over abandoned projects\n' "${SYM_BULLET}"
  printf '%s DBT package customization\n' "${SYM_BULLET}"
  printf '\n'
  
  printf '%s%s%s Three Ways to Use%s\n' "${C_BOLD}${C_GREEN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sInteractive Mode%s (Guided wizard):\n' "${SYM_ARROW}" "${C_MAGENTA}${C_BOLD}" "${C_RESET}"
  printf '  %sgit-clone-and-own%s\n' "${C_MAGENTA}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '%s %sDirect Personal%s:\n' "${SYM_ARROW}" "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '  %sgit-clone-as-personal <source-url> <new-name> [visibility]%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '%s %sDirect Business%s:\n' "${SYM_ARROW}" "${C_BLUE}${C_BOLD}" "${C_RESET}"
  printf '  %sgit-clone-as-business <source-url> <new-name> [visibility]%s\n' "${C_BLUE}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s Step-by-Step Process%s\n' "${C_BOLD}${C_YELLOW}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s 1. Clone the source repository\n' "${SYM_ARROW}"
  printf '%s 2. Remove original remote\n' "${SYM_ARROW}"
  printf '%s 3. Configure git identity for target account\n' "${SYM_ARROW}"
  printf '%s 4. Create new GitHub repository\n' "${SYM_ARROW}"
  printf '%s 5. Set new remote and push\n' "${SYM_ARROW}"
  printf '\n'
  
  printf '%s%s%s Repository Creation Methods%s\n' "${C_BOLD}${C_CYAN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sGitHub CLI%s (preferred if available):\n' "${SYM_CHECK}" "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '  Automatically creates repo and pushes\n'
  printf '%s %sManual Fallback%s (if CLI unavailable):\n' "${SYM_INFO}" "${C_YELLOW}${C_BOLD}" "${C_RESET}"
  printf '  Pauses for you to create repo manually on GitHub\n'
  printf '\n'
  
  printf '%s%s%s Example Scenarios%s\n' "${C_BOLD}${C_RED}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sPersonal Project Template%s:\n' "${SYM_BULLET}" "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '  %sgit-clone-as-personal microsoft/vscode-extension-samples my-vscode-ext private%s\n' "${C_DIM}" "${C_RESET}"
  printf '\n'
  printf '%s %sBusiness DBT Package%s:\n' "${SYM_BULLET}" "${C_BLUE}${C_BOLD}" "${C_RESET}"
  printf '  %sgit-clone-as-business dbt-labs/dbt-utils porch-dbt-utils private%s\n' "${C_DIM}" "${C_RESET}"
  printf '\n'
  printf '%s %sOpen Source Fork%s:\n' "${SYM_BULLET}" "${C_MAGENTA}${C_BOLD}" "${C_RESET}"
  printf '  %sgit-clone-and-own  # Use interactive mode for complex setup%s\n' "${C_DIM}" "${C_RESET}"
}

_git_help_workflows() {
  printf '%s%s%s Complete Workflow Scenarios%s\n' "${C_BOLD}${C_BLUE}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s Scenario 1: Start New Personal Project%s\n' "${C_BOLD}${C_GREEN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Create project directory and files\n' "${SYM_ARROW}"
  printf '%s Switch to personal identity: %suse-personal%s\n' "${SYM_ARROW}" "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '%s Initialize and create repo: %sgit-bootstrap-here --repo my-project%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Work on your project...\n' "${SYM_ARROW}"
  printf '\n'
  
  printf '%s%s%s Scenario 2: Contribute to Business Project%s\n' "${C_BOLD}${C_BLUE}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Clone business repo: %sgit-clone-business porchanalytics/analytics-pipeline%s\n' "${SYM_ARROW}" "${C_BLUE}${C_BOLD}" "${C_RESET}"
  printf '%s Switch to business identity: %suse-business%s\n' "${SYM_ARROW}" "${C_BLUE}${C_BOLD}" "${C_RESET}"
  printf '%s Verify identity: %sgit-whoami%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Make changes and commit\n' "${SYM_ARROW}"
  printf '\n'
  
  printf '%s%s%s Scenario 3: Customize DBT Package%s\n' "${C_BOLD}${C_MAGENTA}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Clone and own: %sgit-clone-and-own%s (interactive)\n' "${SYM_ARROW}" "${C_MAGENTA}${C_BOLD}" "${C_RESET}"
  printf '  - Source: dbt-labs/dbt-utils\n'
  printf '  - New name: porch-dbt-utils  \n'
  printf '  - Account: Business\n'
  printf '  - Visibility: Private\n'
  printf '%s Customize macros and models\n' "${SYM_ARROW}"
  printf '%s Test changes: %sdbt test%s\n' "${SYM_ARROW}" "${C_DIM}" "${C_RESET}"
  printf '%s Commit and push customizations\n' "${SYM_ARROW}"
  printf '\n'
  
  printf '%s%s%s Scenario 4: Switch Existing Repo Account%s\n' "${C_BOLD}${C_YELLOW}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Check current setup: %sgit-whoami && git-remote-info%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Switch identity: %suse-business%s\n' "${SYM_ARROW}" "${C_BLUE}${C_BOLD}" "${C_RESET}"
  printf '%s Switch remote: %sgit-remote-business new-repo-name%s\n' "${SYM_ARROW}" "${C_BLUE}${C_BOLD}" "${C_RESET}"
  printf '%s Push to new remote: %sgit push -u origin main%s\n' "${SYM_ARROW}" "${C_DIM}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s Scenario 5: Troubleshoot Setup%s\n' "${C_BOLD}${C_RED}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Test SSH connections: %sgit-test-ssh%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Check loaded keys: %sgit-list-ssh-keys%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Verify GitHub CLI: %sgit-gh-setup%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Run diagnostics: %sgit-doctor%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
}

_git_help_setup() {
  printf '%s%s%s Initial Setup Guide%s\n' "${C_BOLD}${C_CYAN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s 1. SSH Keys Configuration%s\n' "${C_BOLD}${C_GREEN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Generate SSH keys (if needed):\n' "${SYM_ARROW}"
  printf '  %sssh-keygen -t ed25519 -C "personal" -f ~/.ssh/id_ed25519_personal%s\n' "${C_DIM}" "${C_RESET}"
  printf '  %sssh-keygen -t ed25519 -C "business" -f ~/.ssh/id_ed25519_business%s\n' "${C_DIM}" "${C_RESET}"
  printf '%s Setup SSH hosts: %sgit-setup-ssh-hosts%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Add keys to GitHub (personal and business accounts)\n' "${SYM_ARROW}"
  printf '%s Test connections: %sgit-test-ssh%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s 2. Configuration File%s\n' "${C_BOLD}${C_BLUE}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf 'Create %s~/.config/git-account-manager/config.sh%s:\n' "${C_BOLD}" "${C_RESET}"
  printf '%sGAM_PERSONAL_NAME="Your Name"%s\n' "${C_DIM}" "${C_RESET}"
  printf '%sGAM_PERSONAL_EMAIL="personal@example.com"%s\n' "${C_DIM}" "${C_RESET}"
  printf '%sGAM_PERSONAL_GITHUB="your-personal-username"%s\n' "${C_DIM}" "${C_RESET}"
  printf '%sGAM_BUSINESS_NAME="Your Name"%s\n' "${C_DIM}" "${C_RESET}"
  printf '%sGAM_BUSINESS_EMAIL="work@company.com"%s\n' "${C_DIM}" "${C_RESET}"
  printf '%sGAM_BUSINESS_GITHUB="company-username"%s\n' "${C_DIM}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s 3. GitHub CLI (Optional)%s\n' "${C_BOLD}${C_MAGENTA}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Install: %sbrew install gh%s (macOS)\n' "${SYM_ARROW}" "${C_DIM}" "${C_RESET}"
  printf '%s Setup: %sgit-gh-setup%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s 4. Personal Access Tokens (Optional)%s\n' "${C_BOLD}${C_YELLOW}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Setup guide: %sgit-token-setup%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s 5. Verification%s\n' "${C_BOLD}${C_RED}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s Run diagnostics: %sgit-doctor%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Check status: %sgit-help%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Test identity switching: %suse-personal && git-whoami%s\n' "${SYM_ARROW}" "${C_GREEN}${C_BOLD}" "${C_RESET}"
}

_git_help_troubleshoot() {
  printf '%s%s%s Problem-Solving Guide%s\n' "${C_BOLD}${C_RED}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s SSH Connection Issues%s\n' "${C_BOLD}${C_YELLOW}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sProblem%s: "Permission denied (publickey)"\n' "${SYM_CROSS}" "${C_RED}${C_BOLD}" "${C_RESET}"
  printf '%s Check SSH config: %scat ~/.ssh/config%s\n' "${SYM_ARROW}" "${C_DIM}" "${C_RESET}"
  printf '%s Verify keys exist: %sls -la ~/.ssh/id_*%s\n' "${SYM_ARROW}" "${C_DIM}" "${C_RESET}"
  printf '%s Test connections: %sgit-test-ssh%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Recreate SSH config: %sgit-setup-ssh-hosts%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s Wrong Identity in Commits%s\n' "${C_BOLD}${C_BLUE}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sProblem%s: Commits show wrong name/email\n' "${SYM_CROSS}" "${C_RED}${C_BOLD}" "${C_RESET}"
  printf '%s Check current identity: %sgit-whoami%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Switch identity: %suse-personal%s or %suse-business%s\n' "${SYM_ARROW}" "${C_GREEN}${C_BOLD}" "${C_RESET}" "${C_BLUE}${C_BOLD}" "${C_RESET}"
  printf '%s Set global if needed: %sgit-personal-global%s\n' "${SYM_ARROW}" "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s GitHub CLI Not Working%s\n' "${C_BOLD}${C_GREEN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sProblem%s: Repository creation fails\n' "${SYM_CROSS}" "${C_RED}${C_BOLD}" "${C_RESET}"
  printf '%s Check CLI status: %sgit-gh-setup%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s Re-authenticate: %sgh auth login%s\n' "${SYM_ARROW}" "${C_DIM}" "${C_RESET}"
  printf '%s Use manual fallback (clone-and-own will prompt)\n' "${SYM_ARROW}"
  printf '\n'
  
  printf '%s%s%s Configuration Issues%s\n' "${C_BOLD}${C_MAGENTA}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sProblem%s: Functions not working\n' "${SYM_CROSS}" "${C_RED}${C_BOLD}" "${C_RESET}"
  printf '%s Check config file: %scat ~/.config/git-account-manager/config.sh%s\n' "${SYM_ARROW}" "${C_DIM}" "${C_RESET}"
  printf '%s Reload shell or re-source the script\n' "${SYM_ARROW}"
  printf '%s Run diagnostics: %sgit-doctor%s\n' "${SYM_ARROW}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  
  printf '%s%s%s Common Diagnostic Commands%s\n' "${C_BOLD}${C_CYAN}" "${BOX_H}${BOX_H}${BOX_H} " "${C_RESET}${C_BOLD}" "${C_RESET}"
  printf '%s %sgit-doctor%s - Complete system check\n' "${SYM_BULLET}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s %sgit-whoami%s - Current identity\n' "${SYM_BULLET}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s %sgit-test-ssh%s - SSH connectivity\n' "${SYM_BULLET}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s %sgit-list-ssh-keys%s - Loaded SSH keys\n' "${SYM_BULLET}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
  printf '%s %sgit-remote-info%s - Remote configuration\n' "${SYM_BULLET}" "${C_CYAN}${C_BOLD}" "${C_RESET}"
}


#!/usr/bin/env bash
if ! (return 0 2>/dev/null); then
  set -Eeuo pipefail
  IFS=$'\n\t'
fi

git-doctor() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-doctor [--fix]"; return 0; }
  local auto_fix="0"
  [[ "${1:-}" = "--fix" ]] && auto_fix="1"
  
  local ok=0
  echo "== git-account-manager doctor =="
  
  # SSH aliases
  local missing_ssh_hosts=()
  for host in "${GAM_PERSONAL_SSH_HOST:-github-personal}" "${GAM_BUSINESS_SSH_HOST:-github-business}"; do
    if getent hosts github.com >/dev/null 2>&1 || ping -c1 -W1 github.com >/dev/null 2>&1; then :; fi
    if grep -qE "^Host[[:space:]]+${host}\b" "$HOME/.ssh/config" 2>/dev/null; then
      echo "✓ SSH host alias present: ${host} -> github.com"
    else
      missing_ssh_hosts+=("${host}")
      if [[ "${auto_fix}" = "1" || "${GAM_AUTO_FIX:-1}" = "1" ]]; then
        printf '%s%s Auto-fixing: setting up SSH host aliases...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
        if git-setup-ssh-hosts 2>/dev/null; then
          echo "✓ SSH host aliases configured"
        else
          echo "✗ Failed to setup SSH host aliases automatically"
          ok=1
        fi
        break
      else
        echo "✗ Missing SSH host alias: ${host}  (fix: run 'git-setup-ssh-hosts')"
        ok=1
      fi
    fi
  done
  
  # gh
  if gam_cmd_exists gh; then
    if gh auth status >/dev/null 2>&1; then
      echo "✓ gh installed & authenticated"
    else
      echo "✗ gh installed but not authenticated (run: gh auth login)"
      ok=1
    fi
  else
    echo "✗ gh not installed (install GitHub CLI; see: gh auth login)"
    ok=1
  fi
  
  # audit log path
  if ! gam__ensure_log_dir 2>/dev/null; then
    if [[ "${auto_fix}" = "1" || "${GAM_AUTO_FIX:-1}" = "1" ]]; then
      printf '%s%s Auto-fixing: creating audit log directory...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
      if mkdir -p "$(dirname "${GAM_LOG_FILE}")"; then
        echo "✓ Audit log directory created"
      else
        echo "✗ Failed to create audit log directory"
        ok=1
      fi
    fi
  fi
  
  if [[ -d "$(dirname "${GAM_LOG_FILE}")" ]]; then
    echo "✓ Audit log directory exists: $(dirname "${GAM_LOG_FILE}")"
  else
    echo "✗ Audit log directory missing: $(dirname "${GAM_LOG_FILE}")"
    ok=1
  fi
  
  # repo checks
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local branch; branch="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
    if [[ -z "${branch}" ]]; then
      if [[ "${auto_fix}" = "1" ]]; then
        printf '%s%s Auto-fixing: creating main branch...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
        if git checkout -b main && git commit --allow-empty -m 'init'; then
          echo "✓ Main branch created"
        else
          echo "✗ Failed to create main branch automatically"
          ok=1
        fi
      else
        echo "✗ No default branch; create one: git checkout -b main && git commit --allow-empty -m 'init'"
        ok=1
      fi
    else
      echo "✓ Current branch: ${branch}"
    fi
    
    if gam_repo_has_commit; then
      echo "✓ At least one commit present"
    else
      if [[ "${auto_fix}" = "1" ]]; then
        printf '%s%s Auto-fixing: creating initial commit...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
        if git add -A && git commit -m 'Initial commit'; then
          echo "✓ Initial commit created"
        else
          echo "✗ Failed to create initial commit automatically"
          ok=1
        fi
      else
        echo "✗ No commits; create: git add -A && git commit -m 'Initial commit'"
        ok=1
      fi
    fi
    
    # If remote host is plain github.com, try to rewrite to configured host alias
    local host_cur; host_cur="$(gam_current_remote_host || true)"
    if [[ -n "${host_cur}" && "${host_cur}" = "github.com" ]]; then
      read -r _owner _repo <<<"$(gam_extract_owner_repo_from_remote || true)"
      if [[ -n "${_owner}" && -n "${_repo}" ]]; then
        local inferred=""; [[ "${_owner}" = "${GAM_BUSINESS_GITHUB:-}" ]] && inferred="business"
        [[ -z "${inferred}" && "${_owner}" = "${GAM_PERSONAL_GITHUB:-}" ]] && inferred="personal"
        if [[ -n "${inferred}" ]]; then
          if [[ "${auto_fix}" = "1" || "${GAM_AUTO_FIX:-1}" = "1" ]]; then
            printf '%s%s Auto-fixing: rewriting origin to %s SSH host alias...%s\n' "${C_BLUE}" "${SYM_ARROW}" "${inferred}" "${C_RESET}"
            gam_set_remote_host_for_account "${inferred}" "${_owner}" "${_repo}" || ok=1
          else
            echo "✗ Remote uses github.com; run: git-remote-set --account ${inferred} --owner ${_owner} --repo ${_repo}"
            ok=1
          fi
        fi
      fi
    fi

    # identity vs remote - this will auto-fix if GAM_AUTO_FIX=1
    if ! gam_check_identity_vs_remote; then
      echo "✗ Identity/remote mismatch (see message above). Try: use-personal or use-business"
      ok=1
    else
      echo "✓ Identity matches remote host alias"
    fi
  else
    echo "(Not inside a git repo; skipping repo checks.)"
  fi
  return "${ok}"
}

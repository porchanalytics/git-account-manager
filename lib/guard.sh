#!/usr/bin/env bash
if ! (return 0 2>/dev/null); then
  set -Eeuo pipefail
  IFS=$'\n\t'
fi

# Compliance pre-push guard: ensure email matches remote host alias
# GAM_ENFORCE=1 (default) blocks push; GAM_ENFORCE=0 warns only.
GAM_ENFORCE="${GAM_ENFORCE:-1}"

gam_check_identity_vs_remote() {
  local host; host="$(gam_current_remote_host || true)"
  local email; email="$(gam_current_email || true)"
  if [[ -z "${host}" || -z "${email}" ]]; then
    gam_warn "guard: missing host or email (host=${host:-?} email=${email:-?})"
    return 1
  fi
  local acct; acct="$(gam_account_from_host "${host}")"
  case "${acct}" in
    personal)
      if [[ "${email}" != "${GAM_PERSONAL_EMAIL:-}" ]]; then
        if [[ "${GAM_AUTO_FIX:-1}" = "1" ]]; then
          printf '%s%s Auto-fixing identity mismatch: switching to personal account%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
          use-personal
          return 0
        fi
        [[ "${GAM_ENFORCE}" = "1" ]] && gam_die "Guard: origin uses personal host (${host}) but user.email=${email}. Run: use-personal"
        gam_warn "Guard warn: origin personal (${host}) vs user.email=${email}. Run: use-personal"
        return 1
      fi
      ;;
    business)
      if [[ "${email}" != "${GAM_BUSINESS_EMAIL:-}" ]]; then
        if [[ "${GAM_AUTO_FIX:-1}" = "1" ]]; then
          printf '%s%s Auto-fixing identity mismatch: switching to business account%s\n' "${C_BLUE}" "${SYM_ARROW}" "${C_RESET}"
          use-business
          return 0
        fi
        [[ "${GAM_ENFORCE}" = "1" ]] && gam_die "Guard: origin uses business host (${host}) but user.email=${email}. Run: use-business"
        gam_warn "Guard warn: origin business (${host}) vs user.email=${email}. Run: use-business"
        return 1
      fi
      ;;
    *)
      # Try to infer account from remote URL and auto-fix
      if [[ "${GAM_AUTO_FIX:-1}" = "1" ]]; then
        local inferred_account=""
        if [[ "${host}" =~ github\.com ]]; then
          # Extract owner from git@github.com:owner/repo.git or https://github.com/owner/repo.git
          local remote_url; remote_url="$(git remote get-url origin 2>/dev/null || true)"
          local owner=""
          # Extract owner using sed for reliability
          if [[ "${remote_url}" =~ git@github\.com: ]]; then
            owner=$(echo "${remote_url}" | sed 's|git@github\.com:\([^/]*\)/.*|\1|')
          elif [[ "${remote_url}" =~ github\.com/ ]]; then
            owner=$(echo "${remote_url}" | sed 's|.*github\.com/\([^/]*\)/.*|\1|')
          fi
          
          # Match owner to configured accounts
          if [[ -n "${owner}" ]]; then
            if [[ "${owner}" = "${GAM_PERSONAL_GITHUB:-}" ]]; then
              inferred_account="personal"
            elif [[ "${owner}" = "${GAM_BUSINESS_GITHUB:-}" ]]; then
              inferred_account="business"
            fi
          fi
        fi
        
        if [[ -n "${inferred_account}" ]]; then
          printf '%s%s Auto-fixing unknown host: switching to %s account based on remote owner%s\n' \
            "${C_BLUE}" "${SYM_ARROW}" "${inferred_account}" "${C_RESET}"
          # Align identity first
          case "${inferred_account}" in
            personal) use-personal ;;
            business) use-business ;;
          esac
          # Rewrite remote to use the correct SSH host alias for the account
          gam_set_remote_host_for_account "${inferred_account}" >/dev/null || true
          return 0
        fi
      fi
      gam_warn "Guard: unknown host alias ${host}; configure GAM_*_SSH_HOST or set GAM_AUTO_FIX=0"
      return 1
      ;;
  esac
  return 0
}

git-install-guard-hook() {
  [[ "${1:-}" =~ ^(-h|--help)$ ]] && { echo "Usage: git-install-guard-hook [--global]"; return 0; }
  local global="0"
  [[ "${1:-}" == "--global" ]] && global="1"
  if [[ "${global}" = "1" ]]; then
    local tmpl="$HOME/.git-templates"
    mkdir -p "${tmpl}/hooks"
    cat > "${tmpl}/hooks/pre-push" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
# shellcheck disable=SC1090,SC1091
if [ -n "${GIT_ACCOUNT_MANAGER_SH:-}" ] && [ -f "${GIT_ACCOUNT_MANAGER_SH}" ]; then . "${GIT_ACCOUNT_MANAGER_SH}"; fi
type gam_check_identity_vs_remote >/dev/null 2>&1 && gam_check_identity_vs_remote
EOF
    chmod +x "${tmpl}/hooks/pre-push"
    git config --global init.templateDir "${tmpl}"
    printf 'Installed global pre-push guard via template: %s\n' "${tmpl}"
  else
    gam_require_git_repo
    mkdir -p .git/hooks
    cat > .git/hooks/pre-push <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
# Try to load the toolkit (user must set GIT_ACCOUNT_MANAGER_SH to entrypoint)
# shellcheck disable=SC1090,SC1091
if [ -n "${GIT_ACCOUNT_MANAGER_SH:-}" ] && [ -f "${GIT_ACCOUNT_MANAGER_SH}" ]; then . "${GIT_ACCOUNT_MANAGER_SH}"; fi
type gam_check_identity_vs_remote >/dev/null 2>&1 && gam_check_identity_vs_remote
EOF
    chmod +x .git/hooks/pre-push
    printf 'Installed repo pre-push guard hook.\n'
  fi
}

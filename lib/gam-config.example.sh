# Example private config (copy to: ${XDG_CONFIG_HOME:-$HOME/.config}/git-account-manager/config.sh)
# DO NOT COMMIT REAL VALUES

# Personal account
GAM_PERSONAL_NAME="Your Name"
GAM_PERSONAL_EMAIL="[email protected]"
GAM_PERSONAL_GITHUB="your-github-username"
GAM_PERSONAL_SSH_HOST="github-personal"
GAM_PERSONAL_SSH_KEY="$HOME/.ssh/id_ed25519_personal"

# Business account
GAM_BUSINESS_NAME="Your Corp Name"
GAM_BUSINESS_EMAIL="[email protected]"
GAM_BUSINESS_GITHUB="your-company-username-or-org"
GAM_BUSINESS_SSH_HOST="github-business"
GAM_BUSINESS_SSH_KEY="$HOME/.ssh/id_ed25519_business"

# Compliance and audit (defaults shown)
GAM_ENFORCE=1         # 1=block on mismatch, 0=warn
GAM_AUDIT=1           # 1=log actions, 0=disable
# GAM_LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/git-account-manager/audit.log"




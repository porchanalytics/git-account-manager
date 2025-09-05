# Example private config (copy to: ${XDG_CONFIG_HOME:-$HOME/.config}/git-account-manager/config.sh)
# DO NOT COMMIT REAL VALUES

# Personal account
GAM_PERSONAL_NAME="Daniel Kalleward"
GAM_PERSONAL_EMAIL="d.kalleward@gmail.com"
GAM_PERSONAL_GITHUB="dckallos"
GAM_PERSONAL_SSH_HOST="github-personal"
GAM_PERSONAL_SSH_KEY="/Users/daniel/.ssh/id_ed25519_dckallos"

# Business account
GAM_BUSINESS_NAME="Porch Light Analytics LLC"
GAM_BUSINESS_EMAIL="daniel@porchanalytics.com"
GAM_BUSINESS_GITHUB="porchanalytics"
GAM_BUSINESS_SSH_HOST="github-business"
GAM_BUSINESS_SSH_KEY="/Users/daniel/.ssh/id_ed25519_porchanalytics"

# Compliance and audit (defaults shown)
GAM_ENFORCE=1
GAM_AUDIT=1
# GAM_LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/git-account-manager/audit.log"



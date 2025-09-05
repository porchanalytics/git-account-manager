# Git Account Manager

**Effortlessly manage multiple GitHub accounts with automated identity switching, SSH configuration, and intelligent workflow assistance.**

## The Problem

Modern developers often juggle multiple GitHub identities—personal projects, client work, employer repositories, and open source contributions. Each context requires different git identities (name/email), SSH keys, and access permissions. Manual management leads to:

- **Identity Mix-ups**: Committing personal work with your business email (or vice versa)
- **SSH Key Confusion**: Wrong keys causing authentication failures  
- **Manual Overhead**: Constantly switching `git config` settings and remote URLs
- **Compliance Risks**: Accidentally exposing business code in personal repositories

This project arose from the daily frustration of managing multiple GitHub accounts for a data analytics consultancy. What started as a simple script to switch git identities evolved into a comprehensive automation toolkit that eliminates the mental overhead of context switching.

## The Solution

Git Account Manager provides intelligent automation that:

✅ **Prevents Identity Mix-ups**: Automatic detection and correction of git identity mismatches  
✅ **Simplifies SSH Management**: One-command SSH host alias setup with proper key isolation  
✅ **Streamlines Workflows**: Clone, create, and configure repositories with single commands  
✅ **Enforces Compliance**: Pre-push hooks prevent commits with incorrect identities  
✅ **Provides Visibility**: Comprehensive help system and audit logging

## Quick Start

### Installation

```bash
# Clone and install
git clone https://github.com/dckallos/git-account-manager.git ~/.config/git-account-manager
cd ~/.config/git-account-manager
source bin/git-account-manager.sh

# Add to your shell (one-time setup)
echo 'source ~/.config/git-account-manager/bin/git-account-manager.sh' >> ~/.zshrc
```

### Configuration

Create your private configuration file:

```bash
# Create config (never committed to git)
cp lib/gam-config.example.sh ~/.config/git-account-manager/config.sh
$EDITOR ~/.config/git-account-manager/config.sh
```

Fill in your account details:

```bash
# Personal account
GAM_PERSONAL_NAME="Daniel Kallos"
GAM_PERSONAL_EMAIL="d.kalleward@gmail.com"  
GAM_PERSONAL_GITHUB="dckallos"
GAM_PERSONAL_SSH_KEY="~/.ssh/id_ed25519_personal"

# Business account  
GAM_BUSINESS_NAME="Daniel Kallos"
GAM_BUSINESS_EMAIL="fake-email@porchanalytics.com"
GAM_BUSINESS_GITHUB="porchanalytics"
GAM_BUSINESS_SSH_KEY="~/.ssh/id_ed25519_business"
```

### Initial Setup

```bash
# Set up SSH host aliases (one-time)
git-setup-ssh-hosts

# Test connections
git-test-ssh

# View available commands
git-help
```

## Core Commands

### Identity Management
- `use-personal` - Switch current repo to personal identity
- `use-business` - Switch current repo to business identity  
- `git-whoami` - Show current git identity with account detection
- `git-personal-global` / `git-business-global` - Set global git identity

### Repository Operations
- `git-clone-personal <owner/repo>` - Clone repo using personal account
- `git-clone-business <owner/repo>` - Clone repo using business account
- `git-clone-and-own` - Interactive clone and create your own copy
- `git-bootstrap-here --repo <name>` - Create GitHub repo from current folder
- `git-init-personal <repo>` / `git-init-business <repo>` - Initialize with account

### Remote Management
- `git-remote-set --account <account> --owner <owner> --repo <repo>` - Configure remote
- `git-remote-personal <repo>` / `git-remote-business <repo>` - Quick remote switching
- `git-remote-info` - Show remotes with account indicators

### Diagnostics & Help
- `git-doctor` - Comprehensive system health check with auto-fixes
- `git-help <topic>` - Context-sensitive help (examples, workflows, setup, troubleshooting)
- `git-test-ssh` - Test SSH connections to both accounts
- `git-list-ssh-keys` - Show loaded SSH keys

## Real-World Scenarios

### Scenario 1: Fork and Customize Open Source Libraries

**Context**: You discover a useful open source library but need to customize it for company use while maintaining proper attribution and identity separation.

```bash
# Traditional approach (15+ manual steps, error-prone)
git clone https://github.com/facebook/react.git
cd react
git config user.name "Company Developer"
git config user.email "dev@company.com"
git remote set-url origin git@github-company:company/react-fork.git
gh repo create company/react-fork --private
git push -u origin main
# ... hope you didn't forget anything ...

# Git Account Manager approach (1 interactive command)
git-clone-and-own
# Interactive prompts guide you through:
# Source: facebook/react
# New name: porchanalytics-react-customized  
# Account: business
# Visibility: private
# 
# Result: Perfect setup in 30 seconds with zero configuration errors
```

**What happened automatically:**
- ✅ Repository cloned with correct SSH configuration
- ✅ Business identity configured for all commits
- ✅ Remote pointed to porchanalytics GitHub with proper SSH host alias
- ✅ New repository created on GitHub with specified visibility
- ✅ Audit log entry created for compliance tracking

### Scenario 2: Contributing to Multiple Open Source Projects

**Context**: You're contributing to several open source projects and need consistent personal identity across all contributions.

```bash
# Traditional workflow headaches
cd ~/projects/kubernetes
git config user.email personal@email.com  # Remember to set this every time
git config user.name "Your Name"         # Hope it matches other contributions

cd ~/projects/docker  
git config user.email personal@email.com  # Oops, forgot again
# Submit PR with wrong business email... embarrassing!

# Git Account Manager workflow  
git-clone-personal kubernetes/kubernetes ~/projects/k8s-contrib
git-clone-personal docker/docker ~/projects/docker-contrib
git-clone-personal microsoft/vscode ~/projects/vscode-contrib

# Each repository automatically configured with:
# ✅ Personal identity (consistent name/email)
# ✅ Personal SSH key for authentication
# ✅ Proper remote configuration
# ✅ No manual git config required ever
```

**Quick identity verification across projects:**
```bash
# Check identity in any repository instantly
cd ~/projects/k8s-contrib && git-whoami
# 🟢 Personal Account: Daniel Kallos <d.kalleward@gmail.com>

cd ~/projects/docker-contrib && git-whoami  
# 🟢 Personal Account: Daniel Kallos <d.kalleward@gmail.com>
# Consistent across all personal projects!
```

### Scenario 3: Complex Multi-Client Consulting Workflow

**Context**: Data consultant working on projects for different clients, each requiring separate business identities and repository access.

```bash
# Managing multiple client codebases traditionally
# Client A project
cd ~/work/client-a
git config user.name "Consultant Name"
git config user.email "consultant@client-a.com"
git remote set-url origin git@github.com:client-a/project.git

# Client B project  
cd ~/work/client-b
git config user.name "Consultant Name"  
git config user.email "consultant@client-b.com"
git remote set-url origin git@github.com:client-b/analytics.git
# Repeat for every repository... exhausting!

# Git Account Manager approach with profile switching
# Setup custom client profiles in config.sh:
GAM_CLIENTA_NAME="Daniel Kallos"
GAM_CLIENTA_EMAIL="daniel@client-a.com"
GAM_CLIENTA_GITHUB="client-a-org"
GAM_CLIENTA_SSH_KEY="~/.ssh/id_ed25519_client_a"

GAM_CLIENTB_NAME="Daniel Kallos"  
GAM_CLIENTB_EMAIL="daniel@client-b.com"
GAM_CLIENTB_GITHUB="client-b-org"
GAM_CLIENTB_SSH_KEY="~/.ssh/id_ed25519_client_b"

# Clone with automatic client-specific configuration
git-clone --account clienta --owner client-a-org --repo analytics-dashboard
git-clone --account clientb --owner client-b-org --repo data-pipeline

# Switch contexts instantly as you move between projects
cd ~/work/client-a-dashboard
use-clienta  # Instantly switches to Client A identity

cd ~/work/client-b-pipeline  
use-clientb  # Instantly switches to Client B identity
```

### Scenario 4: Emergency Identity Fix During Live Demo

**Context**: You're presenting your work to stakeholders and realize you've been committing with the wrong identity.

```bash
# The nightmare scenario (traditional git)
git log --oneline
# 5f3a2b1 Add customer dashboard    # Wrong! Should be business email
# 8e1c4d7 Fix authentication bug    # Personal email in business repo
# a9b6e2f Initial implementation    # Identity chaos...

# Manual fix attempt during presentation
git config user.email business@company.com
git rebase -i HEAD~3  # Interactive rebase to fix commits
# ... 10 minutes of git surgery while stakeholders wait ...

# Git Account Manager auto-fix
git push origin main
# System detects identity mismatch:
# 🔧 Auto-fixing identity mismatch: switching to business account
# ✅ Identity corrected for future commits
# 📝 Audit log updated: emergency identity switch

# Alternative: Proactive fix
git-doctor
# 🔍 Analyzing repository health...
# ⚠️  Identity mismatch detected (personal email in business repo)
# 🔧 Auto-fixing: switching to business account
# ✅ Repository configuration corrected
# 💡 Tip: Use git-install-guard-hook to prevent future mix-ups
```

### Scenario 5: Rapid Prototype to Production Pipeline

**Context**: Moving a personal side project into production as a business offering.

```bash
# Traditional migration (manual, error-prone)
cd ~/personal/awesome-analytics-tool
git remote -v  # Check current remote
git remote set-url origin git@github-business:company/analytics-platform.git
git config user.name "Business Name" 
git config user.email "dev@company.com"
gh repo create company/analytics-platform --private
git push origin main
# Cross fingers that everything is configured correctly...

# Git Account Manager migration (foolproof)
cd ~/personal/awesome-analytics-tool

# Method 1: In-place migration
use-business  # Switch current repo to business identity
git-remote-set --account business --owner porchanalytics --repo analytics-platform
# ✅ Repository migrated with proper business configuration

# Method 2: Create clean business copy
git-clone-and-own --src dckallos/awesome-analytics-tool
# Interactive prompts:
# New repository name: analytics-platform
# Target account: business  
# Visibility: private
# ✅ Clean business repository created with complete history
```

### Scenario 6: Collaborative Team Development

**Context**: Working on both internal company projects and external collaborations with partners.

```bash
# Managing mixed internal/external work traditionally
# Internal company project
cd ~/work/internal-api
git config user.email internal@company.com
ssh-add ~/.ssh/company_internal_key

# External collaboration  
cd ~/work/partner-integration
git config user.email external@company.com
ssh-add ~/.ssh/company_external_key
# Managing multiple SSH keys and identities manually...

# Git Account Manager team workflow
# Clone internal company projects
git-clone-business porchanalytics/internal-api
git-clone-business porchanalytics/customer-portal  
git-clone-business porchanalytics/data-pipeline

# Clone external collaboration projects
git-clone --account partner --owner partner-company --repo joint-integration
git-clone --account partner --owner standards-org --repo api-specification

# Seamless context switching
cd ~/work/internal-api
git-whoami
# 🔵 Business Account: Daniel Kallos <fake-email@porchanalytics.com>

cd ~/work/joint-integration  
git-whoami
# 🟡 Partner Account: Daniel Kallos <daniel@external-partner.com>

# Team members can standardize their workflow
git-help workflows  # Share standardized approaches across team
```

### Scenario 7: Teaching and Content Creation

**Context**: Developer creating educational content while maintaining separation between teaching materials and professional work.

```bash
# Managing educational vs professional content
# Create course examples with personal identity
git-clone-personal dckallos/docker-tutorial ./courses/docker-basics
git-clone-personal dckallos/react-examples ./courses/react-fundamentals

# Professional consulting materials with business identity  
git-clone-business porchanalytics/client-workshops ./professional/workshops
git-clone-business porchanalytics/proposal-templates ./professional/templates

# Content creation workflow
cd ~/courses/docker-basics
git-whoami
# 🟢 Personal Account: Daniel Kallos <d.kalleward@gmail.com>
# Perfect for public tutorials and open source examples

cd ~/professional/workshops
git-whoami  
# 🔵 Business Account: Daniel Kallos <fake-email@porchanalytics.com>
# Proper business attribution for professional materials

# Rapid content deployment
git-clone-and-own --src dckallos/tutorial-template
# Transform personal template into client-specific material:
# New name: client-training-materials
# Account: business
# Visibility: private
# ✅ Ready for client delivery with proper business branding
```

### Scenario 8: Compliance and Audit Trail

**Context**: Organization requiring detailed audit trails for code repository access and identity management.

```bash
# Traditional audit challenges
# Manual tracking of who committed what with which identity
# No systematic way to ensure identity compliance
# Difficult to audit cross-repository identity consistency

# Git Account Manager compliance features
# Comprehensive audit logging
tail ~/.local/state/git-account-manager/audit.log
# 2025-09-03T10:15:23Z use-business repo=/work/client-project email=dev@company.com
# 2025-09-03T10:22:41Z clone-business owner=company repo=analytics-dashboard
# 2025-09-03T11:05:17Z identity-fix repo=/work/mixed-project from=personal to=business
# 2025-09-03T11:30:55Z use-personal repo=/personal/side-project email=dev@personal.com

# Proactive compliance enforcement  
git-install-guard-hook --global
# Install pre-push hooks across all repositories

# Result: Automatic identity validation on every push
git push origin feature-branch
# 🔍 Validating identity against remote...
# ✅ Business identity matches business repository
# 🚀 Push proceeding...

# OR if identity mismatch:
# ⚠️  Identity mismatch detected!
# 🛑 Push blocked: personal identity in business repository
# 💡 Run 'use-business' to fix identity and retry

# Systematic compliance verification
git-doctor --audit
# 📊 Repository Compliance Report
# ✅ 15 repositories with correct identity configuration
# ⚠️  2 repositories with mixed commit identities  
# 🔧 3 repositories auto-fixed during scan
# 📈 100% SSH key configuration compliance
```

## Advanced Features

### Auto-Fix Capabilities

The system intelligently handles common issues without manual intervention:

```bash
# Enable auto-fixing (default behavior)
export GAM_AUTO_FIX=1

# Automatic fixes include:
# ✅ SSH host aliases created when missing
# ✅ Identity switched when mismatched with remote 
# ✅ Remote URLs rewritten to SSH host aliases when using github.com
# ✅ Remote URLs inferred from repository owners
# ✅ Audit log directories created automatically
# ✅ Repository permissions detected and applied
# ✅ GitHub CLI authentication verified

# Example auto-fix in action
git push origin main
# 🔧 Auto-fixing SSH host alias: creating github-business entry
# 🔧 Auto-fixing identity mismatch: switching to business account  
# ✅ Repository health restored automatically
# 🚀 Push proceeding with correct configuration
```

### Smart Repository Detection

```bash
# Intelligent account inference from repository context
cd ~/projects/unknown-repo
git-doctor
# 🔍 Analyzing remote URL: git@github.com:company-org/private-project.git
# 🧠 Detected organization: company-org
# 🔧 Auto-configuring business account based on remote
# ✅ Identity synchronized with repository context

# Pattern matching for common scenarios
git-clone https://github.com/kubernetes/kubernetes.git
# 🧠 Detected: Open source project → Personal account recommended
# ✅ Automatically configured with personal identity

git-clone https://github.com/your-company/internal-api.git  
# 🧠 Detected: Company repository → Business account required
# ✅ Automatically configured with business identity
```

### Compliance & Auditing

```bash
# Enterprise-grade audit logging
tail -f ~/.local/state/git-account-manager/audit.log
# 2025-09-03T14:22:15Z clone-business owner=porchanalytics repo=api-service user=fake-email@porchanalytics.com
# 2025-09-03T14:25:33Z identity-switch from=personal to=business repo=/work/api-service
# 2025-09-03T14:30:41Z push-guard-check repo=/work/api-service identity=business status=allowed
# 2025-09-03T14:35:18Z auto-fix ssh-host-missing host=github-business action=created

# Install organization-wide compliance hooks  
git-install-guard-hook --global --strict
# 🛡️  Strict mode: Blocks all identity mismatches
# 📝 Audit trail: All actions logged with timestamps
# 🔒 Compliance: Enforces identity separation policies

# Comprehensive system health monitoring
git-doctor --verbose
# 🔍 SSH Configuration Analysis
#   ✅ github-personal host alias configured  
#   ✅ github-business host alias configured
#   ✅ SSH keys loaded and accessible
# 
# 🔍 Identity Configuration Analysis  
#   ✅ Personal profile: Daniel Kallos <d.kalleward@gmail.com>
#   ✅ Business profile: Daniel Kallos <fake-email@porchanalytics.com>
#   ✅ Current repository identity matches remote
#
# 🔍 Repository Health Check
#   ✅ Remote URLs use correct SSH host aliases
#   ✅ Commit history shows consistent identity usage
#   ✅ Pre-push hooks installed and functional
#
# 🔍 Compliance Status
#   ✅ Audit logging enabled and writable
#   ✅ No identity violations in recent history
#   📊 15 repositories managed, 100% compliant
```

### Advanced Customization

```bash
# Environment-specific configuration
export GAM_AUTO_FIX=1              # Enable intelligent auto-fixes
export GAM_AUDIT=1                 # Enable comprehensive audit logging  
export GAM_ENFORCE=1               # Strict identity enforcement
export GAM_VERBOSE=0               # Quiet mode for scripts

# Custom SSH host aliases (override defaults)
GAM_PERSONAL_SSH_HOST="github-personal"
GAM_BUSINESS_SSH_HOST="github-company" 
GAM_CLIENT_SSH_HOST="github-client"

# Advanced audit configuration
GAM_LOG_FILE="~/.local/state/git-account-manager/audit.log"
GAM_LOG_ROTATION=1                 # Enable log rotation
GAM_LOG_MAX_SIZE="10M"            # Rotate at 10MB
GAM_LOG_RETENTION_DAYS=90         # Keep 90 days of history

# Integration with corporate systems
GAM_LDAP_INTEGRATION=1            # Use LDAP for identity verification
GAM_COMPLIANCE_WEBHOOK="https://compliance.company.com/git-events"
GAM_SLACK_NOTIFICATIONS=1         # Notify team of critical events

# Development vs Production behavior
if [[ "${NODE_ENV}" = "production" ]]; then
  export GAM_ENFORCE=1            # Strict enforcement in production
  export GAM_AUTO_FIX=0           # No automatic changes in production
else
  export GAM_AUTO_FIX=1           # Development auto-fix enabled
  export GAM_ENFORCE=0            # Warnings only in development
fi
```

## Productivity Benefits

### Time Savings Analysis

```bash
# Traditional manual workflow time costs:
# • Initial SSH key setup per repository: ~5 minutes
# • Identity configuration per project: ~2 minutes  
# • Troubleshooting SSH issues: ~15 minutes
# • Recovering from identity mix-ups: ~20 minutes
# • Manual remote URL configuration: ~3 minutes

# Git Account Manager time costs:
# • One-time setup: 10 minutes
# • Per-repository setup: 30 seconds (automated)
# • Identity switching: 5 seconds
# • Issue resolution: Usually automatic

# Example: Managing 20 repositories traditionally
# Setup: 20 × (5 + 2 + 3) = 200 minutes (3.3 hours)
# Maintenance: Monthly issues × 15-20 minutes each
# 
# With Git Account Manager:
# Setup: 10 minutes one-time + 20 × 0.5 minutes = 20 minutes
# Maintenance: Largely automated
#
# 📊 Result: ~90% time savings on git identity management
```

### Developer Experience Improvements

```bash
# Before: Mental overhead and context switching
cd personal-project/        # Remember to check identity
git config user.email       # Verify current settings  
# ... start coding ...
git commit -m "feature"     # Hope identity is correct
git push                    # Cross fingers for SSH access

# After: Zero cognitive load
cd personal-project/        
# Identity automatically correct
git commit -m "feature"     # Confidence in correct attribution
git push                    # SSH always works
```

## Help & Troubleshooting

The system includes comprehensive help for any situation:

```bash
# Context-sensitive help system
git-help                    # 📋 Main overview and command summary
git-help examples          # 💡 Common usage patterns and workflows  
git-help clone-own         # 🔄 Detailed clone-and-own guide
git-help workflows         # 🗃️  Complete end-to-end scenarios
git-help setup            # ⚙️  Initial configuration walkthrough
git-help troubleshoot      # 🔧 Problem-solving and diagnostics

# Command-specific help (all commands support --help)
git-doctor --help         # Comprehensive system diagnostics
git-clone-and-own --help  # Interactive cloning options
use-personal --help       # Identity switching details
```

### Common Issues & Solutions

**SSH Permission Denied**
```bash
# Quick diagnosis and resolution
git-test-ssh              
# 🔍 Testing personal GitHub connection...
# ❌ Permission denied (publickey)
# 💡 Run: git-setup-ssh-hosts to recreate SSH config

git-setup-ssh-hosts       
# 🔧 Creating SSH host aliases...
# ✅ github-personal configured
# ✅ github-business configured  
# 🔧 SSH config updated automatically
```

**Wrong Identity in Commits**
```bash
# Automated detection and correction
git-doctor                
# 🔍 Repository health check...
# ⚠️  Identity mismatch: personal email in business repository
# 🔧 Auto-fixing: switching to business account
# ✅ Future commits will use business identity
# 💡 Tip: Install guard hooks with git-install-guard-hook

# Manual identity correction if needed
use-business              
# 🔄 Switched to business account
# ✅ Identity: Daniel Kallos <fake-email@porchanalytics.com>
```

**Repository Access Issues**  
```bash
# Comprehensive remote analysis
git-remote-info           
# 📍 Current remotes:
# origin: git@github-business:porchanalytics/analytics-platform.git (business account)
# upstream: git@github.com:dckallos/analytics-platform.git (needs configuration)
# 
# 💡 Recommendations:
# • upstream remote should use github-personal for open source contributions

# Automated remote configuration  
git-remote-set --account business --owner porchanalytics --repo analytics-platform
# 🔧 Configuring remote for business account...
# ✅ Remote URL updated: git@github-business:porchanalytics/analytics-platform.git
# ✅ SSH host alias verified
# ✅ Identity configuration synchronized
```

**GitHub CLI Authentication Issues**
```bash
# Streamlined authentication setup
git-gh-setup             
# 🔍 Checking GitHub CLI authentication...
# ❌ Not authenticated for business account
# 🔧 Starting authentication flow...
# 🌐 Opening browser for GitHub authentication...
# ✅ Business account authenticated successfully
# 💡 Tip: Use 'gh auth status' to verify authentication anytime
```

**Configuration Problems**
```bash
# Comprehensive configuration validation
git-doctor --config      
# 🔍 Configuration Analysis:
# ✅ Personal account: All required variables set
# ❌ Business account: Missing GAM_BUSINESS_SSH_KEY
# ❌ SSH key not found: ~/.ssh/id_ed25519_business
# 
# 🔧 Auto-fixes available:
# 1. Generate missing SSH key
# 2. Update configuration with correct path
# 3. Add SSH key to GitHub account
# 
# Run 'git-doctor --fix-config' to apply fixes automatically
```

### Advanced Troubleshooting

```bash
# Deep system analysis for complex issues
git-doctor --deep-scan    
# 🔍 Performing comprehensive system analysis...
# 
# SSH Configuration:
#   ✅ All host aliases configured correctly
#   ✅ SSH keys loaded in ssh-agent
#   ⚠️  Key permissions: 644 (should be 600)
#   🔧 Auto-fixing: chmod 600 applied to SSH keys
# 
# Repository Analysis:
#   📊 Scanning 23 repositories...
#   ✅ 21 repositories: Correct identity configuration
#   ⚠️  2 repositories: Mixed identity commits detected
#   💡 Repositories with issues:
#       • /work/legacy-project (5 personal commits in business repo)
#       • /personal/experiment (1 business commit in personal repo)
# 
# System Integration:
#   ✅ GitHub CLI authenticated for both accounts  
#   ✅ Git global configuration properly isolated
#   ✅ Shell integration working correctly
#   ✅ Audit logging functional
# 
# Performance Metrics:
#   ⚡ Identity switching: 0.12 seconds average
#   ⚡ Repository cloning: 2.3 seconds average overhead
#   📊 System resource usage: Minimal impact
```

## Why This Approach Works

### Before Git Account Manager
- **Manual Context Switching**: Remember to change git config for each project
- **Error-Prone Setup**: Easy to use wrong SSH keys or remote URLs
- **Identity Mix-ups**: Frequent commits with incorrect email addresses
- **Compliance Risk**: Accidental exposure of business code in personal accounts

### After Git Account Manager  
- **Automatic Intelligence**: System detects and corrects configuration issues
- **One-Command Operations**: Complex workflows reduced to single commands
- **Zero Mental Overhead**: No need to remember account-specific configurations  
- **Compliance Built-In**: Pre-push hooks and audit logging ensure proper separation

The result is a development experience where account management becomes invisible, letting you focus on code instead of configuration.

## Contributing

Found a bug or have a feature idea? Contributions welcome!

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Test your changes: `./quick-test.sh`
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Made with ❤️ by developers who got tired of identity mix-ups**

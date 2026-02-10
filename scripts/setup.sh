#!/bin/bash
# WSL2 Development Environment Setup Script
# Usage:
#   ./scripts/setup.sh                    # Full install
#   ./scripts/setup.sh --dry-run          # Preview
#   ./scripts/setup.sh --config minimal   # Minimal install
#   ./scripts/setup.sh --phase 1          # Specific phase only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/lib/common.sh"

# Parse CLI arguments
DRY_RUN=false
CONFIG_NAME="default"
TARGET_PHASE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --config)
            CONFIG_NAME="$2"
            shift 2
            ;;
        --phase)
            TARGET_PHASE="$2"
            shift 2
            ;;
        -h|--help)
            cat << 'EOF'
WSL2 Development Environment Setup v1.0.0

Usage: ./scripts/setup.sh [OPTIONS]

Options:
    --dry-run           Preview without making changes
    --config NAME       Config profile (default, minimal, or path to .conf)
    --phase N           Run only phase N (1-6)
    -h, --help          Show this help

Phases:
    1  CLI Tools (fzf, fd, rg, bat, eza, delta, lazygit, etc.)
    2  Node.js (nvm + LTS)
    3  Neovim + Docker
    4  tmux + TPM
    5  Additional Tools (direnv, jq, yq, atuin, etc.)
    6  System Optimization (WSL settings, services, swap)

Examples:
    ./scripts/setup.sh --dry-run
    ./scripts/setup.sh --config minimal
    ./scripts/setup.sh --phase 1
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1 (use --help for usage)"
            exit 1
            ;;
    esac
done

export DRY_RUN

# Load config
CONFIG_FILE="$SCRIPT_DIR/config/${CONFIG_NAME}.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
    # Try as direct path
    CONFIG_FILE="$CONFIG_NAME"
fi
if [[ ! -f "$CONFIG_FILE" ]]; then
    error_exit "Config not found: $CONFIG_NAME"
fi
# shellcheck disable=SC1090
source "$CONFIG_FILE"
log_info "Loaded config: $CONFIG_FILE"

# Banner
echo ""
echo -e "${BOLD}${CYAN}======================================${NC}"
echo -e "${BOLD}${CYAN}  WSL2 Dev Environment Setup v${SETUP_VERSION}${NC}"
echo -e "${BOLD}${CYAN}======================================${NC}"
if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}  *** DRY RUN MODE ***${NC}"
fi
echo ""

# Pre-flight checks
check_system_requirements

# Ensure install dir exists
mkdir -p "$INSTALL_BIN"
export PATH="$INSTALL_BIN:$PATH"

# Determine phases to run
run_phase() {
    local phase="$1"
    [[ -z "$TARGET_PHASE" ]] || [[ "$TARGET_PHASE" == "$phase" ]]
}

# Count total steps
_phase_count=0
run_phase 1 && [[ "${INSTALL_CLI_TOOLS:-true}" == "true" ]] && _phase_count=$((_phase_count + 1))
run_phase 2 && [[ "${INSTALL_NODEJS:-true}" == "true" ]] && _phase_count=$((_phase_count + 1))
run_phase 3 && [[ "${INSTALL_NEOVIM:-true}" == "true" ]] && _phase_count=$((_phase_count + 1))
run_phase 3 && [[ "${INSTALL_DOCKER:-true}" == "true" ]] && _phase_count=$((_phase_count + 1))
run_phase 4 && [[ "${INSTALL_TMUX:-true}" == "true" ]] && _phase_count=$((_phase_count + 1))
run_phase 5 && [[ "${INSTALL_ADDITIONAL_TOOLS:-true}" == "true" ]] && _phase_count=$((_phase_count + 1))
run_phase 6 && [[ "${INSTALL_SYSTEM_OPTIMIZATION:-true}" == "true" ]] && _phase_count=$((_phase_count + 1))
set_total_steps "$_phase_count"

# Phase 1: CLI Tools
if run_phase 1 && [[ "${INSTALL_CLI_TOOLS:-true}" == "true" ]]; then
    source "$SCRIPT_DIR/lib/cli-tools.sh"
    next_step "CLI Tools"
    setup_cli_tools
fi

# Phase 2: Node.js
if run_phase 2 && [[ "${INSTALL_NODEJS:-true}" == "true" ]]; then
    source "$SCRIPT_DIR/lib/nodejs-setup.sh"
    next_step "Node.js Environment"
    setup_nodejs
fi

# Phase 3: Neovim
if run_phase 3 && [[ "${INSTALL_NEOVIM:-true}" == "true" ]]; then
    source "$SCRIPT_DIR/lib/neovim-setup.sh"
    next_step "Neovim"
    setup_neovim
fi

# Phase 3: Docker
if run_phase 3 && [[ "${INSTALL_DOCKER:-true}" == "true" ]]; then
    source "$SCRIPT_DIR/lib/docker-setup.sh"
    next_step "Docker"
    setup_docker
fi

# Phase 4: tmux
if run_phase 4 && [[ "${INSTALL_TMUX:-true}" == "true" ]]; then
    source "$SCRIPT_DIR/lib/tmux-setup.sh"
    next_step "tmux + TPM"
    setup_tmux
fi

# Phase 5: Additional Tools
if run_phase 5 && [[ "${INSTALL_ADDITIONAL_TOOLS:-true}" == "true" ]]; then
    source "$SCRIPT_DIR/lib/additional-tools.sh"
    next_step "Additional Tools"
    setup_additional_tools
fi

# Phase 6: System Optimization
if run_phase 6 && [[ "${INSTALL_SYSTEM_OPTIMIZATION:-true}" == "true" ]]; then
    source "$SCRIPT_DIR/lib/system-optimization.sh"
    next_step "System Optimization"
    setup_system_optimization
fi

# Summary
echo ""
echo -e "${BOLD}${GREEN}======================================${NC}"
echo -e "${BOLD}${GREEN}  Setup Complete!${NC}"
echo -e "${BOLD}${GREEN}======================================${NC}"
echo ""
echo -e "Log file: ${CYAN}$LOG_FILE${NC}"
if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}This was a dry run. No changes were made.${NC}"
else
    echo -e "Run ${CYAN}source ~/.bashrc${NC} to reload your shell."
fi
echo ""

#!/bin/bash
# Phase 4: tmux + TPM setup module

_TMUX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "${SETUP_VERSION:-}" ]] && source "$_TMUX_DIR/common.sh"

install_tmux() {
    if command_exists tmux; then
        log_info "tmux is already installed ($(tmux -V))"
        return 0
    fi

    log_info "Installing tmux..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} sudo apt-get install -y tmux"
        return 0
    fi

    execute_cmd sudo apt-get update -qq
    execute_cmd sudo apt-get install -y tmux
    log_info "tmux installed"
}

install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ -d "$tpm_dir" ]]; then
        log_info "TPM is already installed"
        return 0
    fi

    log_info "Installing TPM (tmux Plugin Manager)..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} git clone tpm -> ~/.tmux/plugins/tpm"
        return 0
    fi

    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    log_info "TPM installed. Run prefix + I inside tmux to install plugins."
}

install_mosh() {
    if command_exists mosh; then
        log_info "mosh is already installed"
        return 0
    fi

    log_info "Installing mosh..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} sudo apt-get install -y mosh"
        return 0
    fi

    execute_cmd sudo apt-get install -y mosh
    log_info "mosh installed"
}

setup_tmux() {
    log_step "Setting up tmux..."
    install_tmux
    install_tpm
    install_mosh
    log_info "tmux setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_tmux
fi

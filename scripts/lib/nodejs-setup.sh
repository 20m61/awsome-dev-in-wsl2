#!/bin/bash
# Phase 2: Node.js environment setup module

_NODEJS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "${SETUP_VERSION:-}" ]] && source "$_NODEJS_DIR/common.sh"

install_nvm() {
    if [[ -d "$HOME/.nvm" ]]; then
        log_info "nvm is already installed"
        return 0
    fi

    log_info "Installing nvm..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} curl install nvm"
        return 0
    fi

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"

    log_info "nvm installed"
}

install_nodejs() {
    log_info "Installing Node.js LTS..."

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} nvm install --lts"
        return 0
    fi

    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"

    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'

    log_info "Node.js $(node --version) installed"
}

install_global_packages() {
    local packages=("${GLOBAL_NODE_PACKAGES[@]:-typescript}")

    log_info "Installing global npm packages: ${packages[*]}"

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        for pkg in "${packages[@]}"; do
            echo -e "  ${YELLOW}[DRY RUN]${NC} npm install -g $pkg"
        done
        return 0
    fi

    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"

    for pkg in "${packages[@]}"; do
        if npm list -g "$pkg" &>/dev/null; then
            log_info "$pkg is already installed"
        else
            log_info "Installing $pkg..."
            npm install -g "$pkg"
        fi
    done

    log_info "Global npm packages installed"
}

setup_nodejs() {
    log_step "Setting up Node.js environment..."
    install_nvm
    install_nodejs
    install_global_packages
    log_info "Node.js environment setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_nodejs
fi

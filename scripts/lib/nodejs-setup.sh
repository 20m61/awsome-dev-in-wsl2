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

    local nvm_version
    nvm_version=$(_github_latest_tag "nvm-sh/nvm")
    if [[ -z "$nvm_version" ]]; then
        log_warning "Failed to detect nvm version, falling back to v0.40.3"
        nvm_version="v0.40.3"
    fi
    local tmp_script
    tmp_script=$(mktemp)
    if ! curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" -o "$tmp_script"; then
        log_error "Failed to download nvm install script"
        rm -f "$tmp_script"
        return 1
    fi
    bash "$tmp_script"
    rm -f "$tmp_script"

    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
        log_error "nvm.sh not found. NVM installation may have failed."
        return 1
    fi
    \. "$NVM_DIR/nvm.sh"

    log_info "nvm installed"
}

install_nodejs() {
    local node_version="${NODE_VERSION:-lts}"
    log_info "Installing Node.js (${node_version})..."

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} nvm install ${node_version}"
        return 0
    fi

    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
        log_error "nvm.sh not found. Install nvm first."
        return 1
    fi
    \. "$NVM_DIR/nvm.sh"

    if [[ "$node_version" == "lts" ]]; then
        if ! nvm install --lts; then
            log_error "Failed to install Node.js LTS"
            return 1
        fi
        nvm use --lts || { log_error "Failed to activate Node.js LTS"; return 1; }
        nvm alias default 'lts/*' || log_warning "Failed to set default alias"
    else
        if ! nvm install "$node_version"; then
            log_error "Failed to install Node.js ${node_version}"
            return 1
        fi
        nvm use "$node_version" || { log_error "Failed to activate Node.js ${node_version}"; return 1; }
        nvm alias default "$node_version" || log_warning "Failed to set default alias"
    fi

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
    if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
        log_error "nvm.sh not found. Install nvm first."
        return 1
    fi
    \. "$NVM_DIR/nvm.sh"

    local failures=0
    for pkg in "${packages[@]}"; do
        if npm list -g --depth=0 "$pkg" &>/dev/null; then
            log_info "$pkg is already installed"
        else
            log_info "Installing $pkg..."
            if ! npm install -g "$pkg"; then
                log_error "Failed to install $pkg"
                ((failures++))
            fi
        fi
    done

    if [[ "$failures" -gt 0 ]]; then
        log_warning "npm packages: $failures package(s) failed to install"
        return 1
    fi
    log_info "Global npm packages installed"
}

setup_nodejs() {
    log_step "Setting up Node.js environment..."
    install_nvm || return 1
    install_nodejs || return 1
    install_global_packages || return 1
    log_info "Node.js environment setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_nodejs
fi

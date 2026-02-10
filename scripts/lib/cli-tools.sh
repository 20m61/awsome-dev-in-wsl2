#!/bin/bash
# Phase 1: CLI Tools installation module

_CLI_TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "${SETUP_VERSION:-}" ]] && source "$_CLI_TOOLS_DIR/common.sh"

# fzf - special install via git clone
install_fzf() {
    if [[ -d "$HOME/.fzf" ]]; then
        log_info "fzf is already installed"
        return 0
    fi

    log_info "Installing fzf..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} git clone fzf -> ~/.fzf && install"
        return 0
    fi

    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-update-rc
    log_info "fzf installed"
}

# zoxide - special install via curl
install_zoxide() {
    if command_exists zoxide; then
        log_info "zoxide is already installed"
        return 0
    fi

    log_info "Installing zoxide..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} curl install zoxide"
        return 0
    fi

    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    log_info "zoxide installed"
}

# starship - special install via curl
install_starship() {
    if command_exists starship; then
        log_info "starship is already installed"
        return 0
    fi

    log_info "Installing starship..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} curl install starship -> ~/.local/bin"
        return 0
    fi

    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$INSTALL_BIN" -y
    log_info "starship installed"
}

# gh (GitHub CLI) - special install via apt
install_gh() {
    if command_exists gh; then
        log_info "gh is already installed"
        return 0
    fi

    log_info "Installing GitHub CLI..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} apt install gh"
        return 0
    fi

    # Official GitHub CLI install for Ubuntu/Debian
    (type -p wget >/dev/null || execute_cmd sudo apt-get install wget -y) &&
    execute_cmd sudo mkdir -p -m 755 /etc/apt/keyrings &&
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    execute_cmd sudo apt-get update -qq &&
    execute_cmd sudo apt-get install gh -y
    log_info "gh installed"
}

# btop - install via snap or apt
install_btop() {
    if command_exists btop; then
        log_info "btop is already installed"
        return 0
    fi

    log_info "Installing btop..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} snap install btop"
        return 0
    fi

    if command_exists snap; then
        execute_cmd sudo snap install btop
    else
        execute_cmd sudo apt-get install -y btop 2>/dev/null || log_warning "btop: snap not available, skipping"
    fi
    log_info "btop installed"
}

setup_cli_tools() {
    log_step "Installing CLI tools..."

    # GitHub Release-based tools (install_github_release pattern)
    # Args: REPO BINARY PATTERN

    install_github_release "sharkdp/fd" "fd" \
        "fd-v{VERSION}-x86_64-unknown-linux-musl.tar.gz"

    install_github_release "BurntSushi/ripgrep" "rg" \
        "ripgrep-{VERSION}-x86_64-unknown-linux-musl.tar.gz"

    install_github_release "sharkdp/bat" "bat" \
        "bat-v{VERSION}-x86_64-unknown-linux-musl.tar.gz"

    install_github_release "eza-community/eza" "eza" \
        "eza_x86_64-unknown-linux-musl.tar.gz"

    install_github_release "dandavison/delta" "delta" \
        "delta-{VERSION}-x86_64-unknown-linux-musl.tar.gz"

    install_github_release "jesseduffield/lazygit" "lazygit" \
        "lazygit_{VERSION}_Linux_x86_64.tar.gz"

    install_github_release "muesli/duf" "duf" \
        "duf_{VERSION}_linux_amd64.deb"

    install_github_release "dundee/gdu" "gdu" \
        "gdu_linux_amd64_static.tgz" "" "gdu_linux_amd64_static"

    install_github_release "chmln/sd" "sd" \
        "sd-v{VERSION}-x86_64-unknown-linux-musl.tar.gz"

    install_github_release "ducaale/xh" "xh" \
        "xh-v{VERSION}-x86_64-unknown-linux-musl.tar.gz"

    install_github_release "sharkdp/hyperfine" "hyperfine" \
        "hyperfine-v{VERSION}-x86_64-unknown-linux-musl.tar.gz"

    install_github_release "jesseduffield/lazydocker" "lazydocker" \
        "lazydocker_{VERSION}_Linux_x86_64.tar.gz"

    # Special install methods
    install_fzf
    install_zoxide
    install_starship
    install_gh
    install_btop

    log_info "CLI tools installation complete"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_cli_tools
fi

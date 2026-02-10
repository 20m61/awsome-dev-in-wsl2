#!/bin/bash
# Phase 3: Neovim setup module

_NEOVIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "${SETUP_VERSION:-}" ]] && source "$_NEOVIM_DIR/common.sh"

install_neovim() {
    if command_exists nvim; then
        log_info "Neovim is already installed ($(nvim --version | head -1))"
        return 0
    fi

    log_info "Installing Neovim..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} Download Neovim latest release -> ~/.local/"
        return 0
    fi

    local version
    version=$(_github_latest_tag "neovim/neovim")
    if [[ -z "$version" ]]; then
        log_error "Failed to get latest Neovim version"
        return 1
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)
    # shellcheck disable=SC2064
    trap "rm -rf -- '${tmp_dir}'" RETURN

    if ! curl -sfL "https://github.com/neovim/neovim/releases/download/${version}/nvim-linux-x86_64.tar.gz" -o "$tmp_dir/nvim.tar.gz"; then
        log_error "Failed to download Neovim ${version}"
        return 1
    fi
    tar xzf "$tmp_dir/nvim.tar.gz" -C "$tmp_dir"
    cp -r "$tmp_dir"/nvim-linux-x86_64/* "$HOME/.local/"

    log_info "Neovim ${version} installed"
}

setup_neovim_config() {
    local config_dir="$HOME/.config/nvim"
    if [[ -f "$config_dir/init.lua" ]]; then
        log_info "Neovim config already exists at $config_dir/init.lua"
        return 0
    fi

    log_info "Neovim config not found. Create ~/.config/nvim/init.lua manually or copy from backup."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} Check Neovim config"
    fi
}

setup_neovim() {
    log_step "Setting up Neovim..."
    install_neovim
    setup_neovim_config
    log_info "Neovim setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_neovim
fi

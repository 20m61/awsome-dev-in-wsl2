#!/bin/bash
# Phase 5: Additional tools module

_ADDTOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "${SETUP_VERSION:-}" ]] && source "$_ADDTOOLS_DIR/common.sh"

install_direnv() {
    if command_exists direnv; then
        log_info "direnv is already installed"
        return 0
    fi

    log_info "Installing direnv..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} Download direnv -> ~/.local/bin/"
        return 0
    fi

    local tag
    tag=$(_github_latest_tag "direnv/direnv")
    if [[ -z "$tag" ]]; then
        log_error "Failed to get latest direnv version"
        return 1
    fi
    local version="${tag#v}"
    mkdir -p "$INSTALL_BIN"
    if ! curl -sfL "https://github.com/direnv/direnv/releases/download/v${version}/direnv.linux-amd64" -o "$INSTALL_BIN/direnv"; then
        log_error "Failed to download direnv"
        rm -f "$INSTALL_BIN/direnv"
        return 1
    fi
    chmod +x "$INSTALL_BIN/direnv"
    log_info "direnv installed"
}

install_jq() {
    if command_exists jq; then
        log_info "jq is already installed"
        return 0
    fi

    log_info "Installing jq..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} Download jq -> ~/.local/bin/"
        return 0
    fi

    local tag
    tag=$(_github_latest_tag "jqlang/jq")
    if [[ -z "$tag" ]]; then
        log_error "Failed to get latest jq version"
        return 1
    fi
    local version="${tag#jq-}"
    mkdir -p "$INSTALL_BIN"
    if ! curl -sfL "https://github.com/jqlang/jq/releases/download/jq-${version}/jq-linux-amd64" -o "$INSTALL_BIN/jq"; then
        log_error "Failed to download jq"
        rm -f "$INSTALL_BIN/jq"
        return 1
    fi
    chmod +x "$INSTALL_BIN/jq"
    log_info "jq installed"
}

install_yq() {
    if command_exists yq; then
        log_info "yq is already installed"
        return 0
    fi

    log_info "Installing yq..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} Download yq -> ~/.local/bin/"
        return 0
    fi

    local tag
    tag=$(_github_latest_tag "mikefarah/yq")
    if [[ -z "$tag" ]]; then
        log_error "Failed to get latest yq version"
        return 1
    fi
    local version="${tag#v}"
    mkdir -p "$INSTALL_BIN"
    if ! curl -sfL "https://github.com/mikefarah/yq/releases/download/v${version}/yq_linux_amd64" -o "$INSTALL_BIN/yq"; then
        log_error "Failed to download yq"
        rm -f "$INSTALL_BIN/yq"
        return 1
    fi
    chmod +x "$INSTALL_BIN/yq"
    log_info "yq installed"
}

install_just() {
    install_github_release "casey/just" "just" \
        "just-{VERSION}-x86_64-unknown-linux-musl.tar.gz"
}

install_tldr() {
    if command_exists tldr; then
        log_info "tldr is already installed"
        return 0
    fi

    log_info "Installing tldr (tealdeer)..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} Download tealdeer -> ~/.local/bin/tldr"
        return 0
    fi

    local tag
    tag=$(_github_latest_tag "dbrgn/tealdeer")
    if [[ -z "$tag" ]]; then
        log_error "Failed to get latest tealdeer version"
        return 1
    fi
    local version="${tag#v}"

    mkdir -p "$INSTALL_BIN"
    if ! curl -sfL "https://github.com/dbrgn/tealdeer/releases/download/v${version}/tealdeer-linux-x86_64-musl" -o "$INSTALL_BIN/tldr"; then
        log_error "Failed to download tldr"
        rm -f "$INSTALL_BIN/tldr"
        return 1
    fi
    chmod +x "$INSTALL_BIN/tldr"
    "$INSTALL_BIN/tldr" --update 2>/dev/null || true
    log_info "tldr installed (v${version})"
}

install_uv() {
    if command_exists uv; then
        log_info "uv is already installed"
        return 0
    fi

    log_info "Installing uv (Python package manager)..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} curl install uv"
        return 0
    fi

    local tmp_script
    tmp_script=$(mktemp)
    if ! curl -LsSf https://astral.sh/uv/install.sh -o "$tmp_script"; then
        log_error "Failed to download uv install script"
        rm -f "$tmp_script"
        return 1
    fi
    sh "$tmp_script"
    rm -f "$tmp_script"
    log_info "uv installed"
}

install_atuin() {
    if command_exists atuin; then
        log_info "atuin is already installed"
        return 0
    fi

    log_info "Installing atuin..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} curl install atuin"
        return 0
    fi

    local tmp_script
    tmp_script=$(mktemp)
    if ! curl -sSfL https://setup.atuin.sh -o "$tmp_script"; then
        log_error "Failed to download atuin install script"
        rm -f "$tmp_script"
        return 1
    fi
    sh "$tmp_script"
    rm -f "$tmp_script"
    log_info "atuin installed"
}

install_ghq() {
    install_github_release "x-motemen/ghq" "ghq" \
        "ghq_linux_amd64.zip"
}

setup_additional_tools() {
    log_step "Installing additional tools..."
    local failures=0
    install_direnv  || ((failures++))
    install_jq      || ((failures++))
    install_yq      || ((failures++))
    install_just    || ((failures++))
    install_tldr    || ((failures++))
    install_uv      || ((failures++))
    install_atuin   || ((failures++))
    install_ghq     || ((failures++))
    if [[ "$failures" -gt 0 ]]; then
        log_warning "Additional tools: $failures tool(s) failed to install"
        return 1
    fi
    log_info "Additional tools installation complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_additional_tools
fi

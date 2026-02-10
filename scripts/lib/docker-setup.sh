#!/bin/bash
# Phase 3: Docker setup module

_DOCKER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "${SETUP_VERSION:-}" ]] && source "$_DOCKER_DIR/common.sh"

install_docker() {
    if command_exists docker; then
        log_info "Docker is already installed ($(docker --version))"
        return 0
    fi

    log_info "Installing Docker..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} curl -fsSL https://get.docker.com | sudo sh"
        echo -e "  ${YELLOW}[DRY RUN]${NC} sudo usermod -aG docker $USER"
        return 0
    fi

    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$USER"
    log_info "Docker installed. Re-login required for group membership."
}

configure_docker() {
    log_info "Configuring Docker for WSL2..."

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} Configure Docker log rotation"
        return 0
    fi

    # Docker daemon config for log rotation
    local daemon_json="/etc/docker/daemon.json"
    if [[ ! -f "$daemon_json" ]]; then
        sudo mkdir -p /etc/docker
        sudo tee "$daemon_json" > /dev/null << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
EOF
        log_info "Docker log rotation configured"
    else
        log_info "Docker daemon.json already exists, skipping"
    fi
}

setup_docker() {
    log_step "Setting up Docker..."
    install_docker
    configure_docker
    log_info "Docker setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_docker
fi

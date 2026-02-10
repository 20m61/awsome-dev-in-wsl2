#!/bin/bash
# Phase 6: System optimization module (WSL2-specific)

_SYSOPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "${SETUP_VERSION:-}" ]] && source "$_SYSOPT_DIR/common.sh"

configure_swappiness() {
    local target="${SWAPPINESS:-10}"
    local current
    current=$(cat /proc/sys/vm/swappiness 2>/dev/null || echo "unknown")

    if [[ "$current" == "$target" ]]; then
        log_info "Swappiness already set to $target"
        return 0
    fi

    log_info "Setting swappiness to $target (current: $current)..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} sudo sysctl vm.swappiness=$target"
        echo -e "  ${YELLOW}[DRY RUN]${NC} echo 'vm.swappiness=$target' | sudo tee /etc/sysctl.d/99-swappiness.conf"
        return 0
    fi

    execute_cmd sudo sysctl "vm.swappiness=$target"
    echo "vm.swappiness=$target" | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null
    log_info "Swappiness set to $target"
}

disable_unnecessary_services() {
    local services=(
        "avahi-daemon"
        "packagekit"
        "wpa_supplicant"
    )

    log_info "Disabling unnecessary services for WSL2..."
    for svc in "${services[@]}"; do
        if systemctl is-enabled "$svc" &>/dev/null; then
            log_info "Disabling $svc..."
            if [[ "${DRY_RUN:-false}" == "true" ]]; then
                echo -e "  ${YELLOW}[DRY RUN]${NC} sudo systemctl disable --now $svc"
            else
                execute_cmd sudo systemctl disable --now "$svc" 2>/dev/null || true
            fi
        else
            log_info "$svc is already disabled or not installed"
        fi
    done
}

disable_native_mysql() {
    if systemctl is-enabled mysql &>/dev/null; then
        log_info "Disabling native MySQL (Docker replaces it)..."
        if [[ "${DRY_RUN:-false}" == "true" ]]; then
            echo -e "  ${YELLOW}[DRY RUN]${NC} sudo systemctl disable --now mysql"
        else
            execute_cmd sudo systemctl stop mysql 2>/dev/null || true
            execute_cmd sudo systemctl disable mysql 2>/dev/null || true
        fi
    else
        log_info "Native MySQL is already disabled or not installed"
    fi
}

show_wsl_config_reminder() {
    echo ""
    log_info "WSL2 host-side configuration reminder:"
    echo -e "  Create/edit ${CYAN}C:\\Users\\<username>\\.wslconfig${NC}:"
    echo "  [wsl2]"
    echo "  memory=8GB"
    echo "  swap=4GB"
    echo "  vmIdleTimeout=300"
    echo ""
    echo -e "  After changes, restart WSL: ${CYAN}wsl --shutdown${NC}"
}

setup_system_optimization() {
    log_step "Optimizing system for WSL2..."
    configure_swappiness
    disable_unnecessary_services
    disable_native_mysql
    show_wsl_config_reminder
    log_info "System optimization complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_system_optimization
fi

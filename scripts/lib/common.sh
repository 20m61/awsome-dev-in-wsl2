#!/bin/bash
# Common functions and utilities for WSL2 setup scripts

readonly SETUP_VERSION="1.0.0"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Directories
readonly INSTALL_BIN="$HOME/.local/bin"
readonly BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d-%H%M%S)"
readonly LOG_DIR="$HOME/.setup-logs"
readonly LOG_FILE="$LOG_DIR/setup-$(date +%Y%m%d-%H%M%S).log"

# Step counter
_CURRENT_STEP=0
_TOTAL_STEPS=0

set_total_steps() {
    _TOTAL_STEPS=$1
}

next_step() {
    _CURRENT_STEP=$((_CURRENT_STEP + 1))
    echo ""
    echo -e "${BOLD}${CYAN}=== Step ${_CURRENT_STEP}/${_TOTAL_STEPS}: $1 ===${NC}"
    log_to_file "STEP ${_CURRENT_STEP}/${_TOTAL_STEPS}: $1"
}

# Logging
log_to_file() {
    [[ -d "$LOG_DIR" ]] || mkdir -p "$LOG_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
    log_to_file "INFO: $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    log_to_file "ERROR: $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    log_to_file "WARN: $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
    log_to_file "STEP: $1"
}

# Error handling
error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Backup a config file before modifying
backup_config() {
    local file="$1"
    if [[ -f "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        local dest="$BACKUP_DIR/$(basename "$file")"
        cp "$file" "$dest"
        log_info "Backup: $file -> $dest"
    fi
}

# Execute command with dry-run support
execute_cmd() {
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} $*"
        return 0
    else
        "$@"
    fi
}

# Install binary from GitHub Release
# Usage: install_github_release REPO BINARY PATTERN [STRIP_COMPONENTS] [EXTRACT_NAME]
#   REPO: owner/repo (e.g., sharkdp/fd)
#   BINARY: final binary name (e.g., fd)
#   PATTERN: asset filename pattern with {VERSION} placeholder
#   STRIP_COMPONENTS: (optional) tar strip-components for nested archives
#   EXTRACT_NAME: (optional) name of binary inside archive if different from BINARY
install_github_release() {
    local repo="$1"
    local binary="$2"
    local pattern="$3"
    local strip="${4:-}"
    local extract_name="${5:-$binary}"

    if command_exists "$binary"; then
        log_info "$binary is already installed ($(command -v "$binary"))"
        return 0
    fi

    log_info "Installing $binary from $repo..."

    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} Download $repo latest release -> $INSTALL_BIN/$binary"
        return 0
    fi

    local version
    version=$(curl -sL "https://api.github.com/repos/$repo/releases/latest" | grep -oP '"tag_name": "\K[^"]+')
    if [[ -z "$version" ]]; then
        log_error "Failed to get latest version for $repo"
        return 1
    fi

    # Strip leading 'v' for pattern substitution
    local ver_no_v="${version#v}"
    local url="https://github.com/$repo/releases/download/$version/${pattern//\{VERSION\}/$ver_no_v}"

    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap "rm -rf '$tmp_dir'" RETURN

    log_info "Downloading $url"
    if ! curl -sL "$url" -o "$tmp_dir/archive"; then
        log_error "Failed to download $binary"
        return 1
    fi

    mkdir -p "$INSTALL_BIN"

    case "$url" in
        *.tar.gz|*.tgz)
            if [[ -n "$strip" ]]; then
                tar xzf "$tmp_dir/archive" -C "$tmp_dir" --strip-components="$strip"
                mv "$tmp_dir/$extract_name" "$INSTALL_BIN/$binary"
            else
                tar xzf "$tmp_dir/archive" -C "$tmp_dir"
                # Find the binary in extracted files
                local found
                found=$(find "$tmp_dir" -name "$extract_name" -type f | head -1)
                if [[ -n "$found" ]]; then
                    mv "$found" "$INSTALL_BIN/$binary"
                else
                    log_error "Binary $extract_name not found in archive"
                    return 1
                fi
            fi
            ;;
        *.deb)
            dpkg -x "$tmp_dir/archive" "$tmp_dir/deb_extracted"
            local found
            found=$(find "$tmp_dir/deb_extracted" -name "$extract_name" -type f | head -1)
            if [[ -n "$found" ]]; then
                mv "$found" "$INSTALL_BIN/$binary"
            else
                log_error "Binary $extract_name not found in deb"
                return 1
            fi
            ;;
        *)
            # Direct binary download
            mv "$tmp_dir/archive" "$INSTALL_BIN/$binary"
            ;;
    esac

    chmod +x "$INSTALL_BIN/$binary"
    log_info "$binary installed successfully to $INSTALL_BIN/$binary"
}

# Check WSL2 + Ubuntu requirements
check_system_requirements() {
    log_step "Checking system requirements..."

    # Check not running as root
    if [[ $EUID -eq 0 ]]; then
        error_exit "Do not run this script as root."
    fi

    # Check architecture
    local arch
    arch=$(uname -m)
    if [[ "$arch" != "x86_64" ]]; then
        log_warning "This script is designed for x86_64. Current: $arch"
    fi

    # Check Ubuntu
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        if [[ "$ID" != "ubuntu" ]]; then
            log_warning "This script is designed for Ubuntu. Current: ${PRETTY_NAME:-unknown}"
        fi
    fi

    # Check WSL2
    if [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
        log_info "WSL2 environment detected"
    else
        log_warning "WSL2 not detected. Some optimizations may not apply."
    fi

    # Check internet
    if ! curl -s --head --fail --max-time 5 https://github.com >/dev/null 2>&1; then
        error_exit "No internet connection. Please check your network."
    fi

    # Check disk space (minimum 2GB)
    local available_kb
    available_kb=$(df "$HOME" | tail -1 | awk '{print $4}')
    local available_gb=$((available_kb / 1024 / 1024))
    if [[ "$available_gb" -lt 2 ]]; then
        error_exit "Insufficient disk space. Available: ${available_gb}GB, Required: 2GB"
    fi

    log_info "System requirements OK"
}

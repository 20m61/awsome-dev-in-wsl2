# Architecture

## Design Principles

1. **Modular** - Each phase is a self-contained module in `scripts/lib/`
2. **Idempotent** - Every install function checks before acting
3. **Non-destructive** - Config files are backed up before modification
4. **Configurable** - Feature toggles via `.conf` files
5. **Observable** - Color console output + timestamped log files
6. **Testable** - Dry-run mode + automated test suite

## Execution Flow

```
setup.sh (entry point)
│
├── Parse CLI args (--dry-run, --config, --phase)
├── Source lib/common.sh (shared utilities)
├── Load config/*.conf (feature toggles)
├── check_system_requirements()
│   ├── Verify non-root
│   ├── Check architecture (x86_64)
│   ├── Verify Ubuntu OS
│   ├── Detect WSL2
│   ├── Check internet connectivity
│   └── Verify disk space (2GB+)
│
├── Phase 1: lib/cli-tools.sh
│   ├── install_github_release() x12 (fd, rg, bat, eza, delta, ...)
│   ├── install_fzf()        (git clone)
│   ├── install_zoxide()     (curl installer)
│   ├── install_starship()   (curl installer)
│   ├── install_gh()         (apt)
│   └── install_btop()       (snap)
│
├── Phase 2: lib/nodejs-setup.sh
│   ├── install_nvm()
│   ├── install_nodejs()     (LTS)
│   └── install_global_packages()
│
├── Phase 3: lib/neovim-setup.sh
│   ├── install_neovim()     (GitHub release)
│   └── setup_neovim_config()
│
├── Phase 3: lib/docker-setup.sh
│   ├── install_docker()     (get.docker.com)
│   └── configure_docker()   (log rotation)
│
├── Phase 4: lib/tmux-setup.sh
│   ├── install_tmux()       (apt)
│   ├── install_tpm()        (git clone)
│   └── install_mosh()       (apt)
│
├── Phase 5: lib/additional-tools.sh
│   ├── install_direnv()     (GitHub binary)
│   ├── install_jq()         (GitHub binary)
│   ├── install_yq()         (GitHub binary)
│   ├── install_just()       (install_github_release)
│   ├── install_tldr()       (GitHub binary)
│   ├── install_uv()         (curl installer)
│   ├── install_atuin()      (curl installer)
│   └── install_ghq()        (install_github_release)
│
├── Phase 6: lib/system-optimization.sh
│   ├── configure_swappiness()
│   ├── disable_unnecessary_services()
│   ├── disable_native_mysql()
│   └── show_wsl_config_reminder()
│
└── Summary banner + log file path
```

## Key Functions (lib/common.sh)

### Logging

```bash
log_info "message"      # Green [INFO]   + file log
log_error "message"     # Red [ERROR]    + file log (stderr)
log_warning "message"   # Yellow [WARN]  + file log
log_step "message"      # Blue [STEP]    + file log
```

### Progress Tracking

```bash
set_total_steps 7       # Set total
next_step "Phase Name"  # Increment and display "=== Step N/M: Phase Name ==="
```

### Install Helper

```bash
# Generic GitHub Release installer
# Handles: .tar.gz, .tgz, .deb, direct binary
install_github_release "owner/repo" "binary_name" "asset_pattern_{VERSION}.tar.gz"

# Pattern: {VERSION} is replaced with the latest release version (without 'v' prefix)
# The function:
# 1. Checks if binary already exists (skip if so)
# 2. Fetches latest version from GitHub API
# 3. Downloads asset to temp dir
# 4. Extracts and moves binary to ~/.local/bin/
# 5. Sets executable permission
```

### Dry-Run

```bash
execute_cmd sudo apt-get install -y tmux
# In dry-run mode: prints "[DRY RUN] sudo apt-get install -y tmux"
# In normal mode: executes the command
```

### Config Backup

```bash
backup_config ~/.bashrc
# Creates ~/.config-backup/<timestamp>/bashrc
```

## Configuration

Config files are plain bash sourced at startup:

```bash
# config/default.conf
INSTALL_CLI_TOOLS=true
INSTALL_NODEJS=true
INSTALL_NEOVIM=true
INSTALL_DOCKER=true
INSTALL_TMUX=true
INSTALL_ADDITIONAL_TOOLS=true
INSTALL_SYSTEM_OPTIMIZATION=true
GLOBAL_NODE_PACKAGES=("typescript" "ts-node" "prettier" "@biomejs/biome")
SWAPPINESS=10
```

Custom configs can extend or override:

```bash
./scripts/setup.sh --config /path/to/custom.conf
```

## Install Strategies

| Strategy | Tools | Method |
|----------|-------|--------|
| `install_github_release` | fd, rg, bat, eza, delta, lazygit, duf, gdu, sd, xh, hyperfine, lazydocker, just, ghq | GitHub API + download |
| Git clone | fzf, TPM | `git clone --depth 1` |
| Curl installer | zoxide, starship, nvm, uv, atuin | Pipe to sh |
| apt/snap | tmux, mosh, btop, gh | System package manager |
| get.docker.com | Docker | Official installer |

## Dotfiles Snippets (`scripts/dotfiles/`)

Reusable shell configuration snippets that are sourced from `~/.bashrc` or referenced by `~/.gitconfig`:

| File | Purpose |
|------|---------|
| `bashrc-worktree.sh` | `wt` command: git worktree + tmux + Claude Code integration |
| `gitconfig-worktree.ini` | Git worktree alias reference (`wta`, `wtl`, `wtr`, `wtp`) |

These files are managed within this repository and sourced at shell startup, keeping `~/.bashrc` clean while enabling version-controlled shell extensions.

## File Locations

| What | Where |
|------|-------|
| Installed binaries | `~/.local/bin/` |
| Log files | `~/.setup-logs/` |
| Config backups | `~/.config-backup/<timestamp>/` |
| fzf | `~/.fzf/` |
| nvm | `~/.nvm/` |
| TPM | `~/.tmux/plugins/tpm/` |
| Neovim | `~/.local/bin/nvim` + `~/.local/share/nvim/` |

## Testing

```bash
# Run all tests
bash scripts/tests/test-dry-run.sh

# Tests include:
# - Shell syntax validation for all scripts
# - Dry-run execution (exits 0, no side effects)
# - DRY RUN markers present in output
# - Setup Complete banner found
# - Config files loadable
# - All modules source cleanly
```

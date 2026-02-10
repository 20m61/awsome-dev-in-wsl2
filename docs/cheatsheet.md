# Cheatsheet

## Table of Contents

- [Setup Commands](#setup-commands)
- [CLI Tool Replacements](#cli-tool-replacements)
- [Shell Shortcuts](#shell-shortcuts)
- [Git Worktree + tmux (`wt`)](#git-worktree--tmux-wt)
- [tmux](#tmux)
- [Neovim](#neovim)
- [FZF](#fzf)
- [Data Processing](#data-processing)
- [Benchmarking](#benchmarking)
- [Claude Code](#claude-code)
- [WSL2 Tips](#wsl2-tips)
- [Make Targets](#make-targets)
- [Troubleshooting](#troubleshooting)

---

## Setup Commands

```bash
# Setup
./scripts/setup.sh                    # Full install (Phase 1-6)
./scripts/setup.sh --dry-run          # Preview (no changes)
./scripts/setup.sh --config minimal   # Essential tools only
./scripts/setup.sh --phase 1          # Specific phase only
./scripts/setup.sh --help             # Show all options

# Diagnostics
make status                           # Tool installation status + system info
make doctor                           # Syntax check all scripts
make test                             # Run automated dry-run tests
make backup                           # Backup dotfiles
```

### Phase Overview

| Phase | Content | sudo |
|-------|---------|------|
| 1 | CLI Tools (fzf, fd, rg, bat, eza, delta, lazygit, etc.) | No |
| 2 | Node.js (nvm + LTS + global packages) | No |
| 3 | Neovim + Docker | Docker only |
| 4 | tmux + TPM + mosh | Yes |
| 5 | Additional Tools (direnv, jq, yq, just, atuin, ghq, etc.) | No |
| 6 | System Optimization (swappiness, services, WSL config) | Yes |

---

## CLI Tool Replacements

| Classic | Modern | Alias | Example |
|---------|--------|-------|---------|
| `ls` | `eza` | `ls`, `ll`, `la`, `lt` | `lt` = tree view |
| `cat` | `bat` | `cat`, `catp` (with pager) | `bat -l json file.json` |
| `find` | `fd` | `find` | `fd '\.ts$'` = find .ts files |
| `grep` | `ripgrep` | `grep` | `rg 'TODO' --type ts` |
| `sed` | `sd` | - | `sd 'old' 'new' file` |
| `curl` | `xh` | `http` | `xh GET api.example.com` |
| `cd` | `zoxide` | `z`, `zi` | `z proj` = smart jump |
| `top` | `btop` | `top` | CPU/RAM/disk/network |
| `df` | `duf` | `df` | Disk usage table |
| `du` | `gdu` | `du` | Interactive disk usage |
| `diff` | `delta` | (via git pager) | Auto-used in git diff |
| `man` | `tldr` | - | `tldr tar` = quick examples |

---

## Shell Shortcuts

### Navigation

| Command | Description |
|---------|-------------|
| `Ctrl+g` | ghq + fzf: jump to any repository |
| `gl` | ghq + fzf + lazygit (NOT `git pull`) |
| `z <dir>` | zoxide: smart cd (learns from usage) |
| `zi` | zoxide: interactive selection with fzf |
| `ff <name>` | fzf file search with bat preview |
| `fcd` | fzf directory jump |
| `..` / `...` / `....` | cd up 1/2/3 levels |
| `mkcd <dir>` | Create directory and cd into it |

### Git

| Command | Description |
|---------|-------------|
| `gs` | `git status` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gpl` | `git pull` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
| `glog` | `git log --oneline --graph --decorate -20` |
| `gia` | Interactive git add (fzf) |
| `gib` | Interactive branch checkout (fzf) |
| `lg` | lazygit (TUI) |

### Docker

| Command | Description |
|---------|-------------|
| `d` | `docker` |
| `dc` | `docker compose` |
| `dps` | `docker ps` |
| `dimg` | `docker images` |
| `dex` | Interactive container exec (fzf) |
| `lzd` | lazydocker (TUI) |

### WordPress (Docker)

| Command | Description |
|---------|-------------|
| `wp-up <project>` | Start project (aimy: port 8088, tkc: port 8090) |
| `wp-down <project>` | Stop project |
| `wp-stop-all` | Stop all projects |
| `wp-status` | Show running containers with ports |

> WSL2 Note: All containers use `restart: "no"` to prevent auto-start on boot.

### Node.js

| Command | Description |
|---------|-------------|
| `ni` | `npm install` |
| `nr` | `npm run` |
| `nrd` | `npm run dev` |
| `nrb` | `npm run build` |
| `nrt` | `npm run test` |

### Mosh (Mobile Shell)

| Command | Description |
|---------|-------------|
| `mosh user@host` | Connect (auto-reconnect on network change) |
| `mosh --ssh="ssh -p 2222" user@host` | Connect with custom SSH port |
| `mosh-server-status` | Show running mosh-server processes |
| `mosh-kill-all` | Kill all mosh-server processes |

### Config Editing

| Command | Description |
|---------|-------------|
| `bashrc` | Edit ~/.bashrc |
| `gitconfig` | Edit ~/.gitconfig |
| `tmuxconf` | Edit ~/.tmux.conf |
| `reload` | Reload .bashrc |

### Utilities

| Command | Description |
|---------|-------------|
| `extract <file>` | Universal archive extractor (.tar.gz, .zip, .7z, etc.) |
| `note [name]` | Quick notes (opens editor) |
| `sysinfo` | Show system info |

---

## Git Worktree + tmux (`wt`)

### Commands

| Command | Description |
|---------|-------------|
| `wt add <branch>` | Create worktree + tmux session |
| `wt add <branch> --base <ref>` | Create from specific ref/tag/commit |
| `wt ls` | List worktrees with tmux status (● active / ○ none) |
| `wt switch` | fzf picker with preview (branch, path, recent commits) |
| `wt rm <branch>` | Remove worktree + kill session (with safety prompts) |
| `wt review <pr#>` | Checkout PR as worktree (requires gh CLI) |
| `wt cd [branch]` | cd into worktree (fzf picker if no arg) |
| `wt help` | Show help |

### Worktree Workflow Example

```bash
# 1. Create feature branch worktree
wt add feature/auth

# 2. Automatic tmux session created: "repo-name/feature-auth"
#    Windows: editor | claude | shell (+ server/docker if detected)

# 3. Switch between worktrees
wt switch                   # fzf picker

# 4. Review a PR
wt review 42                # Creates worktree for PR #42

# 5. Cleanup
wt rm feature/auth          # Removes worktree + kills tmux session
```

### Directory Structure

```
<repo>/.worktrees/<branch-name>/     # Worktree location
```

### Safety Features

- Branch name validation (`git check-ref-format`)
- Uncommitted change detection before removal
- Confirmation prompts for destructive actions
- Option to delete branch after worktree removal

### Git Worktree Aliases

| Alias | Command |
|-------|---------|
| `git wta` | `git worktree add` |
| `git wtl` | `git worktree list` |
| `git wtr` | `git worktree remove` |
| `git wtp` | `git worktree prune` |

### Auto-Created tmux Session Layout

Session name: `<repo-name>/<branch>` (sanitized)

| Window | Purpose | Condition |
|--------|---------|-----------|
| editor | Neovim | Always |
| claude | Claude Code CLI | Always |
| shell | General terminal | Always |
| server | Dev server | If `package.json` exists |
| docker | Container management | If `docker-compose.yml` / `compose.yml` exists |

---

## tmux

**Prefix:** `Ctrl+a` (or `Ctrl+b`)

### Auto-Attach Behavior

Terminal startup automatically manages tmux sessions:

| Sessions | Behavior |
|----------|----------|
| 0 | Create `main` session |
| 1 | Auto-attach to it |
| 2+ | Show list, select by number |

### Session Management

| Key / Command | Description |
|---------------|-------------|
| `prefix + s` | Session list (tree view) |
| `prefix + Ctrl+s` | fzf session switcher |
| `prefix + N` | New named session |
| `prefix + R` | Rename session |
| `prefix + Q` | Kill session (confirm) |

### Bash Helpers

| Command | Description |
|---------|-------------|
| `t` | fzf session picker / create `main` |
| `t <name>` | Attach or create (with project detection) |
| `tls` | List sessions |
| `tkill <name>` | Kill session |

### Project Detection (`t <name>`)

| Detected File | Windows Created |
|---------------|-----------------|
| `package.json` | editor, server, test |
| `docker-compose.yml` | editor, docker, logs |
| `Cargo.toml` | editor, build, test |
| (none) | single window |

### Window & Pane

| Key | Description |
|-----|-------------|
| `prefix + c` | New window |
| `prefix + ,` | Rename window |
| `prefix + Ctrl+h/l` | Previous/next window |
| `prefix + </>` | Swap window left/right |
| `prefix + \|` | Vertical split |
| `prefix + -` | Horizontal split |
| `prefix + h/j/k/l` | Navigate panes (vim-tmux-navigator) |
| `prefix + H/J/K/L` | Resize panes |
| `prefix + Tab` | Cycle panes |
| `prefix + x` | Kill pane |
| `prefix + X` | Kill window |
| `prefix + S` | Sync panes toggle |
| `prefix + r` | Reload config |

### Popups

| Key | Description |
|-----|-------------|
| `prefix + g` | lazygit |
| `prefix + b` | btop |
| `prefix + t` | Floating terminal |
| `prefix + F` | tmux-fzf |

### Copy Mode (vi)

| Key | Description |
|-----|-------------|
| `prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Copy and cancel |
| `Escape` | Cancel |

### Status Bar

```
[ session]                    [ CPU%]  [󰍛 RAM%]  [󰃰 2026-02-10 11:00]
```

| Module | Icon | Color | Source |
|--------|------|-------|--------|
| CPU |  | Yellow (#f9e2af) | tmux-cpu |
| RAM | 󰍛 | Green (#a6e3a1) | tmux-cpu |
| Date/Time | 󰃰 | Blue (#74c7ec) | built-in |

> No battery module (WSL2 has no battery info).

### Plugins (TPM)

| Plugin | Description |
|--------|-------------|
| tmux-sensible | Sensible defaults |
| tmux-resurrect | Session persistence (save/restore) |
| tmux-continuum | Auto save/restore sessions |
| tmux-yank | Clipboard integration |
| tmux-cpu | CPU/RAM monitoring |
| vim-tmux-navigator | Seamless vim-tmux pane navigation |
| tmux-fzf | fzf integration |
| catppuccin/tmux v2 | Theme (Mocha) |

Install plugins: `prefix + I` (after TPM setup)

### Mosh + tmux Workflow

```bash
# 1. Connect to server
mosh myserver

# 2. Auto-attaches to tmux session

# 3. Create named sessions for different tasks
#    prefix + N → "coding"
#    prefix + N → "deploy"

# 4. Switch sessions: prefix + Ctrl+s → fzf

# 5. Network disconnects? Mosh auto-reconnects to same session
```

---

## Neovim

**Leader:** `Space`

### Plugin Stack

| Plugin | Purpose |
|--------|---------|
| lazy.nvim | Package manager |
| Catppuccin Mocha | Theme |
| nvim-tree | File explorer |
| telescope | Fuzzy finder |
| mason + mason-lspconfig | LSP server management |
| nvim-cmp + LuaSnip | Completion + snippets |
| gitsigns | Git indicators |
| lualine | Status line |
| bufferline | Buffer tabs |

### File Operations

| Key | Description |
|-----|-------------|
| `<leader>e` | File tree toggle |
| `<leader>ff` | Find files (telescope) |
| `<leader>fg` | Live grep (telescope) |
| `<leader>fb` | Buffers (telescope) |
| `Tab` / `S-Tab` | Next/prev buffer |

### Code / LSP

| Key | Description |
|-----|-------------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover info |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>f` | Format |

### LSP Setup

```vim
:Mason                        " LSP server manager
:MasonInstall lua_ls ts_ls pyright  " Install servers
:LspInfo                      " Check LSP status
```

### Misc

| Key | Description |
|-----|-------------|
| `<leader>lg` | Lazygit |
| `Ctrl+\` | Toggle terminal |
| `jk` | Exit insert mode |

### Plugin Management

```vim
:Lazy                         " Plugin manager UI
:Lazy sync                    " Update all plugins
:Lazy check                   " Check for updates (manual, auto-check disabled)
```

### WSL2 Clipboard

```lua
-- appendWindowsPath=false requires full paths:
copy  = { ["+"] = "/mnt/c/Windows/System32/clip.exe" }
paste = { ["+"] = "/mnt/c/.../powershell.exe -c ..." }
```

---

## FZF

| Shortcut | Description |
|----------|-------------|
| `Ctrl+t` | File search (insert path) |
| `Ctrl+r` | History search (atuin) |
| `Alt+c` | Directory jump (cd) |

---

## Data Processing

### jq (JSON)

```bash
# Pretty print
cat data.json | jq '.'

# Extract field
jq '.name' package.json

# Filter array
jq '.items[] | select(.active == true)' data.json

# Transform
jq '{name: .name, ver: .version}' package.json
```

### yq (YAML/JSON/XML)

```bash
# Read YAML value
yq '.services.db.image' docker-compose.yml

# Edit YAML in-place
yq -i '.version = "3.9"' docker-compose.yml

# Convert YAML to JSON
yq -o json docker-compose.yml
```

### xh (HTTP client)

```bash
# GET request
xh GET https://api.example.com/users

# POST with JSON body
xh POST https://api.example.com/users name=John email=john@example.com

# With headers
xh GET https://api.example.com Authorization:"Bearer token123"

# Download file
xh -d GET https://example.com/file.zip
```

---

## Benchmarking

### hyperfine

```bash
# Basic benchmark
hyperfine 'fd -e ts'

# Compare two commands
hyperfine 'find . -name "*.ts"' 'fd -e ts'

# With warmup runs
hyperfine --warmup 3 'rg TODO' 'grep -r TODO'

# Export results
hyperfine --export-markdown bench.md 'cmd1' 'cmd2'
```

---

## Claude Code

### Skills (Slash Commands)

| Command | Description |
|---------|-------------|
| `/review <file>` | Code review (security, performance, readability) |
| `/gen-test <file>` | Generate tests (auto-detect framework) |
| `/gen-docs <file>` | Generate documentation (JSDoc/docstring/README) |
| `/wt` | Git worktree operations |
| `/wp` | WordPress Docker project management |

### Token Efficiency Settings

`~/.claude/settings.json` の `env` セクション:

| Variable | Value | Effect |
|----------|-------|--------|
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | `70` | Auto-compaction at 70% context (default: 95%) |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `1` | Enable multi-agent collaboration |

Session tips:
- `claude --effort medium` — Per-session effort level for routine tasks (reduces thinking tokens)
- `/clear` — Reset context between unrelated tasks
- `/compact` — Manual compaction when context feels bloated

### Agent Teams (Experimental)

Multiple Claude Code instances working in parallel:

```
# Spawn teammates with natural language
Spawn 3 teammates to review this PR:
- Security reviewer (use Sonnet)
- Performance reviewer (use Sonnet)
- Test coverage reviewer (use Sonnet)
```

| Feature | Subagents | Agent Teams |
|---------|-----------|-------------|
| Communication | Report to lead only | Direct teammate-to-teammate |
| Use case | Focused single tasks | Complex collaborative work |
| Token cost | Low | High (N teammates ~ N× tokens) |

Controls:
- `Shift+Up/Down` — Switch between teammates (in-process mode)
- Split-panes mode available with tmux
- Shutdown: `Ask <teammate> to shut down`

Best for: parallel code review, hypothesis debugging, independent module development.

### Config Directory Structure

```
~/.claude/
├── settings.json          # Permissions, env vars, hooks
├── settings.local.json    # Machine-specific permissions
├── hooks/
│   └── auto-format.sh     # PostToolUse auto-format
├── skills/
│   ├── review/SKILL.md
│   ├── gen-test/SKILL.md
│   ├── gen-docs/SKILL.md
│   ├── wt/SKILL.md
│   └── wp/SKILL.md
└── projects/
    └── <project>/memory/MEMORY.md  # Cross-session memory
```

### Auto-format Hook

Triggered after Edit/Write operations:

| File Extension | Formatter |
|----------------|-----------|
| `.ts`, `.tsx`, `.js`, `.jsx`, `.json` | `biome format` |
| `.py` | `ruff format` |

Error log: `/tmp/claude-hook-format.log`

### Project-level Instructions

| File | Scope |
|------|-------|
| `~/CLAUDE.md` | Global (all projects) |
| `<project>/CLAUDE.md` | Project-specific |

---

## WSL2 Tips

### Configuration

**Windows side:** `C:\Users\<username>\.wslconfig`

```ini
[wsl2]
memory=8GB
swap=4GB
vmIdleTimeout=300
```

**WSL side:** `/etc/wsl.conf`

```ini
[boot]
systemd=true

[interop]
appendWindowsPath=false    # Faster shell startup
```

### Windows Commands (Full Paths Required)

`appendWindowsPath=false` requires full paths to Windows executables:

```bash
/mnt/c/Windows/System32/clip.exe              # Clipboard
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
/mnt/c/Windows/explorer.exe .                 # Open in Explorer
```

### Git Performance Optimizations

```ini
# ~/.gitconfig
[core]
    fsmonitor = true        # File system change monitoring
    untrackedCache = true   # Cache untracked file status
[feature]
    manyFiles = true        # Optimizations for large repos
```

### Docker in WSL2

- Use `restart: "no"` in docker-compose.yml (prevent auto-start)
- Log rotation: max-size 10m, max-file 3 (`/etc/docker/daemon.json`)
- Start/stop via `wp-up`/`wp-down` helpers

### System Optimization Applied

| Setting | Value | Purpose |
|---------|-------|---------|
| `vm.swappiness` | 10 | Prefer RAM over swap |
| avahi-daemon | disabled | mDNS not needed |
| packagekit | disabled | Background package management |
| wpa_supplicant | disabled | WiFi not needed |
| native MySQL | disabled | Use Docker instead |

### Restart WSL

```powershell
# From PowerShell
wsl --shutdown
```

---

## Make Targets

| Target | Description |
|--------|-------------|
| `make setup` | Run full setup (all phases) |
| `make setup-dry-run` | Preview without changes |
| `make setup-minimal` | Essential tools only |
| `make setup-phase PHASE=N` | Run specific phase (1-6) |
| `make status` | Tool status + system info (memory, disk, swappiness) |
| `make doctor` | Syntax check all scripts (`bash -n`) |
| `make backup` | Backup configs (.bashrc, .gitconfig, .tmux.conf, etc.) |
| `make test` | Run automated test suite |
| `make wp-up PROJECT=aimy` | Start WordPress project |
| `make wp-down PROJECT=aimy` | Stop WordPress project |
| `make wp-stop` | Stop all WordPress projects |
| `make wp-status` | Show Docker container status |
| `make help` | Show all available targets |

---

## File Locations

| What | Where |
|------|-------|
| Installed binaries | `~/.local/bin/` |
| Log files | `~/.setup-logs/setup-YYYYMMDD-HHMMSS.log` |
| Config backups | `~/.config-backup/YYYYMMDD-HHMMSS/` |
| fzf | `~/.fzf/` |
| nvm | `~/.nvm/` |
| TPM | `~/.tmux/plugins/tpm/` |
| Neovim | `~/.local/bin/nvim` + `~/.local/share/nvim/` |
| Repositories | `~/repos/github.com/<user>/<repo>/` (ghq) |

---

## Post-Installation Verification

```bash
# Check all tool status
make status

# Verify key tools
fd --version && rg --version && bat --version
node --version && npm --version
nvim --version | head -1
tmux -V
docker --version

# Verify system optimization
free -h                              # Memory usage
cat /proc/sys/vm/swappiness          # Should be 10
docker ps                            # No auto-started containers
systemctl is-enabled mysql           # Should be disabled
```

---

## Troubleshooting

### Neovim plugins not loading

```bash
nvim --headless "+Lazy sync" +qa     # Re-sync all plugins
```

### LSP not working

```vim
:LspInfo                             " Check LSP status
:Mason                               " Install/manage LSP servers
```

### Clipboard not working in WSL2

```bash
# Test clipboard (appendWindowsPath=false requires full path)
echo "test" | /mnt/c/Windows/System32/clip.exe
```

Neovim clipboard is configured with full paths in `init.lua`.

### mosh connection issues

```bash
# Check firewall on server
sudo ufw status
sudo ufw allow 60000:61000/udp      # mosh uses UDP 60000-61000
```

### tmux status bar not showing CPU/RAM

1. Check plugin order in `~/.tmux.conf`: catppuccin must be before tmux-cpu
2. Verify `@catppuccin_cpu_text` uses `#(script)` format
3. Test scripts directly:

```bash
~/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh   # e.g., 12.5%
~/.tmux/plugins/tmux-cpu/scripts/ram_percentage.sh    # e.g., 26.8%
```

### Windows commands not found

`appendWindowsPath=false` means Windows commands need full paths:

```bash
/mnt/c/Windows/System32/clip.exe
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
/mnt/c/Windows/explorer.exe .
```

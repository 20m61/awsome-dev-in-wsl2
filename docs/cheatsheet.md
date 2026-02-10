# Cheatsheet

## Setup Commands

```bash
./scripts/setup.sh                    # Full install
./scripts/setup.sh --dry-run          # Preview
./scripts/setup.sh --config minimal   # Minimal
./scripts/setup.sh --phase 1          # Phase 1 only
make status                           # Tool status
make doctor                           # Diagnostics
```

---

## CLI Tool Replacements

| Classic | Modern | Alias |
|---------|--------|-------|
| `ls` | `eza` | `ls`, `ll`, `la`, `lt` |
| `cat` | `bat` | `cat`, `catp` (with pager) |
| `find` | `fd` | `find` |
| `grep` | `ripgrep` | `grep` |
| `sed` | `sd` | - |
| `curl` | `xh` | `http` |
| `cd` | `zoxide` | `z`, `zi` |
| `top` | `btop` | `top` |
| `df` | `duf` | `df` |
| `du` | `gdu` | `du` |
| `diff` | `delta` | (via git pager) |

---

## Shell Shortcuts

### Navigation

| Command | Description |
|---------|-------------|
| `Ctrl+g` | ghq + fzf: jump to repository |
| `gl` | ghq + fzf + lazygit |
| `z <dir>` | zoxide: smart cd |
| `ff <name>` | fzf file search with preview |
| `fcd` | fzf directory jump |
| `..` / `...` / `....` | cd up 1/2/3 levels |

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
| `glog` | `git log --oneline --graph` |
| `gia` | Interactive git add (fzf) |
| `gib` | Interactive branch checkout (fzf) |
| `lg` | lazygit |

### Docker

| Command | Description |
|---------|-------------|
| `d` | `docker` |
| `dc` | `docker compose` |
| `dps` | `docker ps` |
| `dimg` | `docker images` |
| `dex` | Interactive container exec (fzf) |
| `lzd` | lazydocker |

### WordPress (Docker)

| Command | Description |
|---------|-------------|
| `wp-up <project>` | Start project (aimy, tkc) |
| `wp-down <project>` | Stop project |
| `wp-stop-all` | Stop all projects |
| `wp-status` | Show running containers |

### Node.js

| Command | Description |
|---------|-------------|
| `ni` | `npm install` |
| `nr` | `npm run` |
| `nrd` | `npm run dev` |
| `nrb` | `npm run build` |
| `nrt` | `npm run test` |

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
| `extract <file>` | Universal archive extractor |
| `mkcd <dir>` | Create directory and cd into it |
| `note [name]` | Quick notes (opens editor) |
| `sysinfo` | Show system info |

---

## tmux Keybindings

**Prefix:** `Ctrl+a` (or `Ctrl+b`)

### Session Management

| Key | Description |
|-----|-------------|
| `prefix + s` | Session list (tree view) |
| `prefix + Ctrl+s` | fzf session switcher |
| `prefix + N` | New named session |
| `prefix + R` | Rename session |
| `prefix + Q` | Kill session (confirm) |

### Bash Helpers

| Command | Description |
|---------|-------------|
| `t` | fzf session picker / create main |
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
| `prefix + h/j/k/l` | Navigate panes |
| `prefix + H/J/K/L` | Resize panes |
| `prefix + x` | Kill pane |
| `prefix + X` | Kill window |
| `prefix + S` | Sync panes toggle |

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

---

## Neovim Keybindings

**Leader:** `Space`

### File Operations

| Key | Description |
|-----|-------------|
| `<leader>e` | File tree toggle |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `Tab` / `S-Tab` | Next/prev buffer |

### Code

| Key | Description |
|-----|-------------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover info |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>f` | Format |

### Misc

| Key | Description |
|-----|-------------|
| `<leader>lg` | Lazygit |
| `Ctrl+\` | Toggle terminal |
| `jk` | Exit insert mode |

---

## FZF

| Shortcut | Description |
|----------|-------------|
| `Ctrl+t` | File search |
| `Ctrl+r` | History search (atuin) |
| `Alt+c` | Directory jump |

---

## Make Targets

```bash
make setup            # Full setup
make setup-dry-run    # Preview
make setup-minimal    # Minimal
make setup-phase PHASE=1  # Specific phase
make status           # Tool status
make doctor           # Syntax check
make backup           # Backup dotfiles
make test             # Run tests
make wp-up PROJECT=aimy   # Start WordPress
make wp-status        # Container status
make help             # All targets
```

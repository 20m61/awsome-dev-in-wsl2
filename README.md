# awsome-dev-in-wsl2

[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![WSL2](https://img.shields.io/badge/WSL2-Windows_11-0078D6?logo=windows&logoColor=white)](https://learn.microsoft.com/en-us/windows/wsl/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)

WSL2 (Ubuntu 24.04) 上に完全な開発環境をワンコマンドで構築するセットアップ自動化スクリプト。

[awsom-devenv-in-ec2](https://github.com/20m61/awsom-devenv-in-ec2) のベストプラクティス（モジュラー設計、dry-run、ロギング）を WSL2 向けに移植。

## Features

- **Idempotent** - 何度実行しても安全。インストール済みツールはスキップ
- **Dry-run mode** - `--dry-run` で実行前に変更内容をプレビュー
- **Modular** - フェーズ別・モジュール別に分離。必要な部分だけ実行可能
- **Configurable** - `default.conf` / `minimal.conf` で構成を切り替え
- **Logged** - カラー付きコンソール出力 + タイムスタンプ付きログファイル
- **Non-destructive** - 設定ファイルは変更前に自動バックアップ

## Quick Start

```bash
# Clone
ghq get 20m61/awsome-dev-in-wsl2
# or
git clone https://github.com/20m61/awsome-dev-in-wsl2.git

cd awsome-dev-in-wsl2

# Preview (no changes)
./scripts/setup.sh --dry-run

# Full install
./scripts/setup.sh

# Minimal install
./scripts/setup.sh --config minimal
```

## What Gets Installed

### Phase 1: CLI Tools

| Tool | Description |
|------|-------------|
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [fd](https://github.com/sharkdp/fd) | Fast file search |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast text search |
| [bat](https://github.com/sharkdp/bat) | Cat with syntax highlighting |
| [eza](https://github.com/eza-community/eza) | Modern ls |
| [delta](https://github.com/dandavison/delta) | Git diff viewer |
| [lazygit](https://github.com/jesseduffield/lazygit) | Git TUI |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter cd |
| [starship](https://starship.rs/) | Customizable prompt |
| [duf](https://github.com/muesli/duf) | Disk usage |
| [gdu](https://github.com/dundee/gdu) | Disk usage TUI |
| [sd](https://github.com/chmln/sd) | Modern sed |
| [xh](https://github.com/ducaale/xh) | Modern curl |
| [hyperfine](https://github.com/sharkdp/hyperfine) | Command benchmarking |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | Docker TUI |
| [gh](https://cli.github.com/) | GitHub CLI |
| [btop](https://github.com/aristocratos/btop) | System monitor |

### Phase 2: Node.js

- **nvm** (Node Version Manager) + Node.js LTS
- Global packages: `typescript`, `ts-node`, `prettier`, `@biomejs/biome`

### Phase 3: Neovim + Docker

- **Neovim** latest release
- **Docker** + log rotation config

### Phase 4: tmux

- **tmux** + **TPM** (Plugin Manager) + **mosh**

### Phase 5: Additional Tools

| Tool | Description |
|------|-------------|
| [direnv](https://direnv.net/) | Directory-based env vars |
| [jq](https://jqlang.github.io/jq/) | JSON processor |
| [yq](https://github.com/mikefarah/yq) | YAML/JSON/XML processor |
| [just](https://github.com/casey/just) | Modern make alternative |
| [tldr](https://github.com/dbrgn/tealdeer) | Simplified man pages |
| [uv](https://github.com/astral-sh/uv) | Fast Python package manager |
| [atuin](https://atuin.sh/) | Shell history with sync |
| [ghq](https://github.com/x-motemen/ghq) | Git repository manager |

### Phase 6: System Optimization

- `vm.swappiness=10` (RAM優先)
- 不要サービス無効化 (avahi-daemon, packagekit, wpa_supplicant)
- ネイティブ MySQL 無効化 (Docker で代替)
- WSL2 `.wslconfig` 設定リマインダ

### Phase 7: Claude Code Configuration

- **settings.json** - 権限設定 (allow/deny)、環境変数、PostToolUse フック
- **Token efficiency** - 自動コンパクション (70%)、effort level 制御、CLAUDE.md 最適化
- **Agent Teams** - マルチエージェント並行作業（並行レビュー、仮説デバッグ等）
- **hooks** - Edit/Write 後の自動フォーマット (biome, ruff)
- **skills** - カスタムスラッシュコマンド (`/review`, `/gen-test`, `/gen-docs`, `/wt`, `/wp`)
- **memory** - プロジェクト別セッション横断メモリ

## Dotfiles Snippets

Shell configuration snippets in `scripts/dotfiles/` that extend your environment:

| Snippet | Description |
|---------|-------------|
| `bashrc-worktree.sh` | `wt` command - git worktree + tmux + Claude Code CLI integration |
| `gitconfig-worktree.ini` | Git worktree aliases (`wta`, `wtl`, `wtr`, `wtp`) |

```bash
# Worktree workflow
wt add feature/auth       # Create worktree + tmux session (editor/claude/shell)
wt switch                 # fzf picker to switch worktree/session
wt review 42              # Review PR #42 as worktree
wt ls                     # List worktrees with tmux status
wt rm feature/auth        # Cleanup worktree + session
```

## Usage

```bash
# Full install (all phases)
./scripts/setup.sh

# Dry-run (preview only)
./scripts/setup.sh --dry-run

# Minimal config
./scripts/setup.sh --config minimal

# Specific phase only
./scripts/setup.sh --phase 1    # CLI tools only
./scripts/setup.sh --phase 3    # Neovim + Docker only

# Check tool status
make status

# Run diagnostics
make doctor

# Backup configs
make backup

# Show all commands
make help
```

## Project Structure

```
awsome-dev-in-wsl2/
├── scripts/
│   ├── setup.sh                 # Main entry point
│   ├── lib/
│   │   ├── common.sh            # Shared utilities (logging, backup, install helpers)
│   │   ├── cli-tools.sh         # Phase 1: CLI tools
│   │   ├── nodejs-setup.sh      # Phase 2: Node.js
│   │   ├── neovim-setup.sh      # Phase 3: Neovim
│   │   ├── docker-setup.sh      # Phase 3: Docker
│   │   ├── tmux-setup.sh        # Phase 4: tmux + TPM
│   │   ├── additional-tools.sh  # Phase 5: direnv, jq, atuin, etc.
│   │   └── system-optimization.sh # Phase 6: WSL2 tuning
│   ├── config/
│   │   ├── default.conf         # Full install profile
│   │   └── minimal.conf         # Minimal install profile
│   ├── dotfiles/
│   │   ├── bashrc-worktree.sh   # wt command (worktree + tmux)
│   │   └── gitconfig-worktree.ini # Git worktree aliases
│   └── tests/
│       └── test-dry-run.sh      # Automated test suite
├── docs/
│   ├── dev-environment-setup.md # Manual setup reference
│   ├── cheatsheet.md            # Tool & keybinding cheatsheet
│   └── architecture.md          # Script architecture guide
├── Makefile                     # Development shortcuts
├── CONTRIBUTING.md              # Contribution guide
├── CLAUDE.md                    # Claude Code instructions
├── LICENSE                      # MIT License
└── README.md
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make setup` | Run full setup |
| `make setup-dry-run` | Preview without changes |
| `make setup-minimal` | Minimal install |
| `make setup-phase PHASE=N` | Run specific phase (1-6) |
| `make status` | Show tool installation status |
| `make doctor` | Check config syntax |
| `make backup` | Backup dotfiles |
| `make test` | Run test suite |
| `make wp-up PROJECT=aimy` | Start WordPress project |
| `make wp-status` | Show Docker containers |
| `make help` | Show all targets |

## Requirements

- **OS**: Ubuntu 24.04 LTS on WSL2
- **Arch**: x86_64
- **Disk**: 2GB+ free space
- **Network**: Internet connection required
- **User**: Non-root user with sudo access

## Related

- [awsom-devenv-in-ec2](https://github.com/20m61/awsom-devenv-in-ec2) - Amazon Linux 2023 version

## License

[MIT](LICENSE)

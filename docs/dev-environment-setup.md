# Development Environment Setup Guide

Ubuntu 24.04 LTS (WSL2) での開発環境構築手順

## Automated Setup (Recommended)

手動手順の代わりに、自動セットアップスクリプトを使用できます:

```bash
# フルインストール
./scripts/setup.sh

# プレビュー (変更なし)
./scripts/setup.sh --dry-run

# 最小構成
./scripts/setup.sh --config minimal

# 特定フェーズのみ
./scripts/setup.sh --phase 1

# ツール状態確認
make status

# ヘルプ
make help
```

スクリプトの詳細: `scripts/setup.sh --help`

以下は手動でのセットアップ手順 (リファレンス) です。

---

## Overview

| Phase | 内容 | sudo |
|-------|------|------|
| 1 | CLI Tools (fzf, fd, rg, bat, eza, etc.) | 不要 |
| 2 | Node.js + Clipboard | 不要 |
| 3 | Neovim + Docker | Docker のみ |
| 4 | Mosh + tmux | 必要 |
| 5 | Additional Tools (direnv, jq, atuin, etc.) | 不要 |
| 6 | Resource Optimization (WSL, services, swap) | 必要 |

---

## Prerequisites

```bash
# 必要なディレクトリ作成
mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"
```

---

## Phase 1: CLI Tools

### 1.1 fzf (Fuzzy Finder)

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
```

### 1.2 fd (Find Alternative)

```bash
FD_VERSION=$(curl -sL https://api.github.com/repos/sharkdp/fd/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar xzf fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz
mv fd-v${FD_VERSION}-x86_64-unknown-linux-musl/fd ~/.local/bin/
rm -rf fd-v${FD_VERSION}-x86_64-unknown-linux-musl*
```

### 1.3 ripgrep (Grep Alternative)

```bash
RG_VERSION=$(curl -sL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep -oP '"tag_name": "\K[^"]+')
curl -sLO "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar xzf ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz
mv ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl/rg ~/.local/bin/
rm -rf ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl*
```

### 1.4 bat (Cat Alternative)

```bash
BAT_VERSION=$(curl -sL https://api.github.com/repos/sharkdp/bat/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar xzf bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz
mv bat-v${BAT_VERSION}-x86_64-unknown-linux-musl/bat ~/.local/bin/
rm -rf bat-v${BAT_VERSION}-x86_64-unknown-linux-musl*
```

### 1.5 eza (ls Alternative)

```bash
EZA_VERSION=$(curl -sL https://api.github.com/repos/eza-community/eza/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-musl.tar.gz"
tar xzf eza_x86_64-unknown-linux-musl.tar.gz
mv eza ~/.local/bin/
rm -f eza_x86_64-unknown-linux-musl.tar.gz
```

### 1.6 zoxide (Smarter cd)

```bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

### 1.7 Starship (Prompt)

```bash
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin -y
```

### 1.8 delta (Git Diff Viewer)

```bash
DELTA_VERSION=$(curl -sL https://api.github.com/repos/dandavison/delta/releases/latest | grep -oP '"tag_name": "\K[^"]+')
curl -sLO "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar xzf delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz
mv delta-${DELTA_VERSION}-x86_64-unknown-linux-musl/delta ~/.local/bin/
rm -rf delta-${DELTA_VERSION}-x86_64-unknown-linux-musl*
```

### 1.9 lazygit (Git TUI)

```bash
LAZYGIT_VERSION=$(curl -sL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xzf lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz lazygit
mv lazygit ~/.local/bin/
rm -f lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz
```

### 1.10 duf (Disk Usage)

```bash
DUF_VERSION=$(curl -sL https://api.github.com/repos/muesli/duf/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/muesli/duf/releases/download/v${DUF_VERSION}/duf_${DUF_VERSION}_linux_amd64.deb"
dpkg -x duf_${DUF_VERSION}_linux_amd64.deb duf_extracted
mv duf_extracted/usr/bin/duf ~/.local/bin/
rm -rf duf_${DUF_VERSION}_linux_amd64.deb duf_extracted
```

### 1.11 gdu (Disk Usage TUI)

```bash
GDU_VERSION=$(curl -sL https://api.github.com/repos/dundee/gdu/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/dundee/gdu/releases/download/v${GDU_VERSION}/gdu_linux_amd64_static.tgz"
tar xzf gdu_linux_amd64_static.tgz
mv gdu_linux_amd64_static ~/.local/bin/gdu
rm -f gdu_linux_amd64_static.tgz
```

---

## Phase 2: Node.js Environment

### 2.1 nvm (Node Version Manager)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Reload shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js LTS
nvm install --lts
nvm use --lts
```

### 2.2 Global npm Packages

```bash
npm install -g typescript ts-node prettier eslint @biomejs/biome
```

### 2.3 WSL2 Clipboard (clip.exe)

WSL2 では Windows の `clip.exe` を使用してクリップボード連携を行う。

```bash
# 確認
ls /mnt/c/Windows/System32/clip.exe
```

---

## Phase 3: Neovim

### 3.1 Neovim Installation

```bash
NVIM_VERSION=$(curl -sL https://api.github.com/repos/neovim/neovim/releases/latest | grep -oP '"tag_name": "\K[^"]+')
curl -sLO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
tar xzf nvim-linux-x86_64.tar.gz
cp -r nvim-linux-x86_64/* ~/.local/
rm -rf nvim-linux-x86_64*
```

### 3.2 Neovim Configuration

設定ファイル: `~/.config/nvim/init.lua`

主な機能:
- Package Manager: lazy.nvim
- Theme: Catppuccin Mocha
- File Explorer: nvim-tree
- Fuzzy Finder: telescope
- LSP: mason + mason-lspconfig
- Completion: nvim-cmp + LuaSnip
- Git: gitsigns
- Status Line: lualine
- Buffer Line: bufferline

最適化設定:
- `checker = { enabled = false }` — プラグイン更新の自動チェック無効 (手動: `:Lazy check`)
- WSL2 クリップボード: `appendWindowsPath=false` 対応でフルパス指定
  ```lua
  -- clip.exe / powershell.exe のフルパスが必要
  copy  = { ["+"] = "/mnt/c/Windows/System32/clip.exe" },
  paste = { ["+"] = "/mnt/c/.../powershell.exe -c ..." },
  ```

### 3.3 First Launch

```bash
# プラグインの自動インストール
nvim

# LSP サーバーのインストール（Neovim 内で）
:MasonInstall lua_ls ts_ls pyright
```

### 3.4 Docker (Optional, requires sudo)

```bash
# Install Docker
curl -fsSL https://get.docker.com | sudo sh

# Add user to docker group
sudo usermod -aG docker $USER

# Re-login to apply
```

### 3.5 Docker Compose の設定方針

WSL2 ではメモリが限られるため、Docker コンテナの自動起動を防止する:

```yaml
# docker-compose.yml で全サービスに設定
services:
  db:
    restart: "no"    # "unless-stopped" や "always" にしない
  wordpress:
    restart: "no"
```

コンテナの起動/停止は bash ヘルパーで管理 (Phase 4 の `.bashrc` 参照):
```bash
wp-up aimy       # プロジェクト起動
wp-down aimy     # プロジェクト停止
wp-stop-all      # 全停止
wp-status        # 状態確認
```

---

## Phase 4: Mosh + tmux (requires sudo)

### 4.1 Mosh Installation

```bash
sudo apt update && sudo apt install -y mosh
```

### 4.2 Firewall (Server-side)

```bash
# mosh uses UDP 60000-61000
sudo ufw allow 60000:61000/udp
```

### 4.3 Mosh の使い方

```bash
# 基本接続
mosh user@hostname

# ポート指定
mosh --ssh="ssh -p 2222" user@hostname

# 接続後は自動で tmux セッションに入る (.bashrc で設定済み)
```

**Mosh の特徴:**
- SSH と違い UDP ベースで、ネットワーク切断後も自動再接続
- Wi-Fi 切替、スリープ復帰後もセッションが維持される
- ローカルエコーによる低遅延な入力体験

**管理コマンド:**

| コマンド | 説明 |
|---------|------|
| `mosh-server-status` | 実行中の mosh-server プロセスを表示 |
| `mosh-kill-all` | 全 mosh-server プロセスを終了 |

### 4.4 tmux セッション管理

ターミナル起動時の自動動作:
- セッション **0個** → `main` セッションを自動作成
- セッション **1個** → そのセッションに自動アタッチ
- セッション **2個以上** → 一覧表示 → 番号選択

**bash ヘルパー:**

| コマンド | 説明 |
|---------|------|
| `t` | fzf でセッション選択 / なければ `main` 作成 |
| `t dev` | `dev` にアタッチ / なければ作成 |
| `tls` | セッション一覧 |
| `tkill <name>` | セッション削除 |

**tmux キーバインド (prefix +):**

| キー | 説明 |
|-----|------|
| `s` | セッション一覧ツリー |
| `Ctrl+s` | fzf でセッション切り替え |
| `N` | 新しい名前付きセッション作成 |
| `R` | セッション名を変更 |
| `Q` | セッション削除（確認あり） |

### 4.5 tmux ステータスバー

右側に CPU/RAM/日時を表示 (Catppuccin v2 + tmux-cpu):

```
[ session]                    [ CPU%]  [󰍛 RAM%]  [󰃰 2026-02-10 11:00]
```

| モジュール | アイコン | 色 | ソース |
|-----------|---------|-----|--------|
| CPU | | 黄 (#f9e2af) | tmux-cpu |
| RAM | 󰍛 | 緑 (#a6e3a1) | tmux-cpu |
| 日時 | 󰃰 | 青 (#74c7ec) | built-in |

> WSL2 にはバッテリーがないため、battery モジュールは非表示。

### 4.6 tmux + Mosh の典型的なワークフロー

```bash
# 1. PC からサーバーに接続
mosh myserver

# 2. 自動で tmux セッションに入る

# 3. 作業用セッションを使い分ける
#    prefix + N → "coding" と入力 → コーディング用セッション
#    prefix + N → "deploy" と入力 → デプロイ用セッション

# 4. セッション間の移動
#    prefix + Ctrl+s → fzf で選択

# 5. ネットワーク切断されても再接続すれば同じセッションに戻れる
```

---

## Phase 5: Additional Tools

### 5.1 direnv (Directory-based Environment)

```bash
DIRENV_VERSION=$(curl -sL https://api.github.com/repos/direnv/direnv/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/direnv/direnv/releases/download/v${DIRENV_VERSION}/direnv.linux-amd64"
chmod +x direnv.linux-amd64
mv direnv.linux-amd64 ~/.local/bin/direnv
```

### 5.2 jq (JSON Processor)

```bash
JQ_VERSION=$(curl -sL https://api.github.com/repos/jqlang/jq/releases/latest | grep -oP '"tag_name": "jq-\K[^"]+')
curl -sLO "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-amd64"
chmod +x jq-linux-amd64
mv jq-linux-amd64 ~/.local/bin/jq
```

### 5.3 yq (YAML/JSON/XML Processor)

```bash
YQ_VERSION=$(curl -sL https://api.github.com/repos/mikefarah/yq/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64"
chmod +x yq_linux_amd64
mv yq_linux_amd64 ~/.local/bin/yq
```

### 5.4 just (Modern Make Alternative)

```bash
JUST_VERSION=$(curl -sL https://api.github.com/repos/casey/just/releases/latest | grep -oP '"tag_name": "\K[^"]+')
curl -sLO "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar xzf just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz just
mv just ~/.local/bin/
rm -f just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz
```

### 5.5 tldr (Simplified Man Pages)

```bash
curl -sLO "https://github.com/dbrgn/tealdeer/releases/download/v1.7.2/tealdeer-linux-x86_64-musl"
chmod +x tealdeer-linux-x86_64-musl
mv tealdeer-linux-x86_64-musl ~/.local/bin/tldr

# Update cache
tldr --update
```

### 5.6 sd (Modern sed Alternative)

```bash
SD_VERSION=$(curl -sL https://api.github.com/repos/chmln/sd/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/chmln/sd/releases/download/v${SD_VERSION}/sd-v${SD_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar xzf sd-v${SD_VERSION}-x86_64-unknown-linux-musl.tar.gz
mv sd-v${SD_VERSION}-x86_64-unknown-linux-musl/sd ~/.local/bin/
rm -rf sd-v${SD_VERSION}-x86_64-unknown-linux-musl*
```

### 5.7 xh (Modern curl Alternative)

```bash
XH_VERSION=$(curl -sL https://api.github.com/repos/ducaale/xh/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/ducaale/xh/releases/download/v${XH_VERSION}/xh-v${XH_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar xzf xh-v${XH_VERSION}-x86_64-unknown-linux-musl.tar.gz
mv xh-v${XH_VERSION}-x86_64-unknown-linux-musl/xh ~/.local/bin/
rm -rf xh-v${XH_VERSION}-x86_64-unknown-linux-musl*
```

### 5.8 hyperfine (Command Benchmarking)

```bash
HYPERFINE_VERSION=$(curl -sL https://api.github.com/repos/sharkdp/hyperfine/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/sharkdp/hyperfine/releases/download/v${HYPERFINE_VERSION}/hyperfine-v${HYPERFINE_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar xzf hyperfine-v${HYPERFINE_VERSION}-x86_64-unknown-linux-musl.tar.gz
mv hyperfine-v${HYPERFINE_VERSION}-x86_64-unknown-linux-musl/hyperfine ~/.local/bin/
rm -rf hyperfine-v${HYPERFINE_VERSION}-x86_64-unknown-linux-musl*
```

### 5.9 lazydocker (Docker TUI)

```bash
LAZYDOCKER_VERSION=$(curl -sL https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sLO "https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
tar xzf lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz lazydocker
mv lazydocker ~/.local/bin/
rm -f lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz
```

### 5.10 uv (Fast Python Package Manager)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 5.11 atuin (Shell History with Sync)

```bash
curl -sSfL https://setup.atuin.sh | sh

# Optional: Register for sync
atuin register
# Or login if you have an account
atuin login
```

---

## Phase 6: Resource Optimization

### 6.1 WSL 設定

**Windows 側: `C:\Users\<username>\.wslconfig`**

```ini
[wsl2]
memory=8GB
swap=4GB
vmIdleTimeout=300
```

**WSL 側: `/etc/wsl.conf`**

```ini
[boot]
systemd=true

[interop]
appendWindowsPath=false
```

> `appendWindowsPath=false` にすると Windows の PATH が追加されなくなりシェル起動が高速化する。
> `clip.exe` 等は Neovim 内でフルパス (`/mnt/c/Windows/System32/clip.exe`) を指定済み。

### 6.2 不要サービスの無効化

```bash
# ネイティブ MySQL (Docker で代替)
sudo systemctl stop mysql && sudo systemctl disable mysql

# WSL で不要なサービス
sudo systemctl disable --now avahi-daemon     # mDNS
sudo systemctl disable --now packagekit       # バックグラウンドパッケージ管理
sudo systemctl disable --now wpa_supplicant   # WiFi
```

### 6.3 Swap / メモリ最適化

```bash
# RAM 優先、スワップ抑制
sudo sysctl vm.swappiness=10
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
```

### 6.4 Docker コンテナの自動起動防止

各 `docker-compose.yml` で `restart: "no"` に設定済み。
必要時のみ `wp-up <project>` で起動。

---

## Configuration Files

> 以下はリファレンス用の抜粋。実際の設定は各ファイルを参照。

### ~/.bashrc (主な追加設定)

```bash
# tmux セッション管理
t()     # fzf でセッション選択 / なければ main 作成
t dev   # dev にアタッチ / なければ作成
tls     # セッション一覧
tkill   # セッション削除

# Docker WordPress プロジェクト管理
wp-up <project>    # プロジェクト起動 (aimy, tkc)
wp-down <project>  # プロジェクト停止
wp-stop-all        # 全プロジェクト停止
wp-status          # 稼働状況確認

# tmux 自動アタッチ (ターミナル起動時)
# - セッション 0個 → main を自動作成
# - セッション 1個 → 自動アタッチ
# - セッション 2個以上 → 番号選択

# Mosh 管理
mosh-server-status  # 実行中の mosh-server 表示
mosh-kill-all       # 全 mosh-server 終了
```

### ~/.gitconfig (抜粋)

```ini
[core]
    editor = nvim
    pager = delta
    fsmonitor = true
    untrackedCache = true

[feature]
    manyFiles = true
```

`fsmonitor` / `untrackedCache` / `manyFiles` で大規模リポジトリの git 操作が高速化。

### ~/.config/starship.toml (抜粋)

```toml
command_timeout = 500  # ms (default: 1000)
```

### ~/.tmux.conf (抜粋)

```bash
set -g status-interval 5   # ステータスバー更新間隔 (秒)
set -g history-limit 10000  # スクロールバックバッファ

# Catppuccin v2 + tmux-cpu: 直接スクリプト呼び出しで互換性を確保
set -g @catppuccin_cpu_text " #(/home/changhwi/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh)"
set -g @catppuccin_load_text " #(/home/changhwi/.tmux/plugins/tmux-cpu/scripts/ram_percentage.sh)"
set -g @catppuccin_load_icon "󰍛 "
set -g @catppuccin_load_color "#a6e3a1"

# ステータスバー右側: CPU + RAM + 日時 (バッテリーは WSL2 で非対応)
set -g status-right "#{E:@catppuccin_status_cpu}#{E:@catppuccin_status_load}#{E:@catppuccin_status_date_time}"
```

> **注意:** Catppuccin v2 は `#{l:#{cpu_percentage}}` で遅延展開するため、tmux-cpu の文字列置換がマッチしない。
> `@catppuccin_cpu_text` / `@catppuccin_load_text` を直接 `#(script)` で上書きすることで解決。
> プラグインのロード順は Catppuccin → tmux-cpu の順にすること。

---

## Installed Tools Summary

### Phase 1-4: Core Tools

| Tool | Version | Description |
|------|---------|-------------|
| fzf | 0.61.3 | Fuzzy finder |
| fd | 10.2.0 | Fast file search |
| ripgrep | 14.1.1 | Fast text search |
| bat | 0.25.0 | Cat with syntax highlighting |
| eza | 0.21.3 | Modern ls |
| zoxide | 0.10.0 | Smarter cd |
| starship | 1.23.0 | Customizable prompt |
| delta | 0.18.2 | Git diff viewer |
| lazygit | 0.51.1 | Git TUI |
| btop | (apt) | System monitor |
| duf | 0.9.1 | Disk usage |
| gdu | 5.32.0 | Disk usage TUI |
| nvm | 0.40.3 | Node version manager |
| Node.js | 24.13.0 | JavaScript runtime |
| npm | 11.6.2 | Package manager |
| Neovim | 0.11.6 | Modern Vim |
| mosh | 1.4.0 | Mobile shell |

### tmux Plugins (TPM)

| Plugin | Description |
|--------|-------------|
| tmux-sensible | Sensible defaults |
| tmux-resurrect | Session persistence |
| tmux-continuum | Auto save/restore |
| tmux-yank | Clipboard integration |
| tmux-cpu | CPU/RAM monitoring |
| vim-tmux-navigator | Vim-tmux pane navigation |
| tmux-fzf | fzf integration |
| catppuccin/tmux v2.1.3 | Theme (Mocha) |

### Phase 5: Additional Tools

| Tool | Version | Description |
|------|---------|-------------|
| gh | 2.86.0 | GitHub CLI |
| direnv | 2.37.1 | Directory-based env vars |
| jq | 1.8.1 | JSON processor |
| yq | 4.52.2 | YAML/JSON/XML processor |
| just | 1.46.0 | Modern make alternative |
| tldr | 1.7.2 | Simplified man pages |
| sd | 1.0.0 | Modern sed alternative |
| xh | 0.25.3 | Modern curl alternative |
| hyperfine | 1.20.0 | Command benchmarking |
| lazydocker | 0.24.4 | Docker TUI |
| uv | 0.9.28 | Fast Python package manager |
| atuin | 18.11.0 | Shell history with sync |

---

## Keybindings Reference

### Neovim

| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `<leader>e` | File tree toggle |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>lg` | Lazygit |
| `Ctrl+\` | Toggle terminal |
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover info |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>f` | Format |
| `Tab` / `S-Tab` | Next/prev buffer |
| `jk` | Exit insert mode |

### tmux

**セッション管理:**

| Key | Action |
|-----|--------|
| `prefix + s` | セッション一覧ツリー |
| `prefix + Ctrl+s` | fzf でセッション切り替え |
| `prefix + N` | 新しい名前付きセッション |
| `prefix + R` | セッション名変更 |
| `prefix + Q` | セッション削除 |

**ウィンドウ・ペイン操作:**

| Key | Action |
|-----|--------|
| `Ctrl+a` / `Ctrl+b` | Prefix |
| `prefix + c` | New window |
| `prefix + ,` | Rename window |
| `prefix + Ctrl+h/Ctrl+l` | Prev/next window |
| `prefix + </>`  | Swap window left/right |
| `prefix + \|` | Vertical split |
| `prefix + -` | Horizontal split |
| `prefix + h/j/k/l` | Navigate panes |
| `prefix + H/J/K/L` | Resize panes |
| `prefix + Tab` | Cycle panes |
| `prefix + x` | Kill pane |
| `prefix + X` | Kill window |
| `prefix + S` | Sync panes toggle |

**ポップアップ:**

| Key | Action |
|-----|--------|
| `prefix + g` | lazygit |
| `prefix + b` | btop |
| `prefix + t` | floating terminal |
| `prefix + F` | tmux-fzf |

**コピーモード (vi):**

| Key | Action |
|-----|--------|
| `prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Copy and cancel |
| `Escape` | Cancel |

**その他:**

| Key | Action |
|-----|--------|
| `prefix + r` | Reload config |

---

## Post-Installation

```bash
# Phase 1-5 完了後
source ~/.bashrc

# Phase 6 (Resource Optimization) 完了後
# WSL の再起動が必要 (PowerShell から実行)
wsl --shutdown

# 再起動後の確認
free -h                    # メモリ使用量
cat /proc/sys/vm/swappiness  # 10 であること
docker ps                  # コンテナが自動起動していないこと
systemctl is-enabled mysql # disabled であること
```

---

## Troubleshooting

### Neovim plugins not loading

```bash
# Re-sync plugins
nvim --headless "+Lazy sync" +qa
```

### LSP not working

```bash
# In Neovim, check LSP status
:LspInfo

# Install LSP servers
:Mason
```

### Clipboard not working in WSL2

`appendWindowsPath=false` の場合、フルパスで指定:
```bash
echo "test" | /mnt/c/Windows/System32/clip.exe
```

Neovim のクリップボード設定 (`init.lua`) もフルパスに設定済み。

### mosh connection issues

Check firewall on server:
```bash
sudo ufw status
sudo ufw allow 60000:61000/udp
```

### tmux ステータスバーに CPU/RAM が表示されない

Catppuccin v2 + tmux-cpu の互換性問題。以下を確認:

1. **プラグイン順序**: `~/.tmux.conf` で `catppuccin/tmux` が `tmux-plugins/tmux-cpu` より前に記述されているか
2. **スクリプト直接呼び出し**: `@catppuccin_cpu_text` が `#(script)` 形式になっているか
3. **スクリプトが動作するか**:
```bash
~/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh  # 例: 12.5%
~/.tmux/plugins/tmux-cpu/scripts/ram_percentage.sh   # 例: 26.8%
```

### Windows コマンドが見つからない

`appendWindowsPath=false` にしたため、Windows コマンドはフルパスが必要:
```bash
/mnt/c/Windows/System32/clip.exe
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
/mnt/c/Windows/explorer.exe .
```

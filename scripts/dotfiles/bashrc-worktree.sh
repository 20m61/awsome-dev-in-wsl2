# Git Worktree + tmux + Claude Code CLI integration
# Source this file from ~/.bashrc
#
# Usage: wt <subcommand> [args]
# Subcommands: add, ls, switch, rm, review, cd, help

# ============================================
# Internal Helpers
# ============================================

# Get the main worktree root (the original clone directory)
_wt_main_root() {
  git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //'
}

# Generate tmux session name from repo + branch
# Example: awsome-dev-in-wsl2/feature-auth
_wt_session_name() {
  local branch="$1"
  local root
  root="$(_wt_main_root)"
  if [[ -z "$root" ]]; then
    echo "wt: not inside a git repository" >&2
    return 1
  fi
  local repo_name
  repo_name="$(basename "$root")"
  # Sanitize branch: replace / with - (tmux session names can't have .)
  local safe_branch="${branch//\//-}"
  echo "${repo_name}/${safe_branch}"
}

# Create tmux session with project-aware windows
# Windows: editor + claude + shell (+ server/docker if detected)
_wt_create_session() {
  local session_name="$1"
  local dir="$2"

  if tmux has-session -t "=$session_name" 2>/dev/null; then
    return 0
  fi

  # Base windows: editor, claude, shell
  tmux new-session -d -s "$session_name" -c "$dir" -n editor
  tmux new-window -t "$session_name" -n claude -c "$dir"
  tmux new-window -t "$session_name" -n shell -c "$dir"

  # Project-type detection: add extra windows
  if [[ -f "$dir/package.json" ]]; then
    tmux new-window -t "$session_name" -n server -c "$dir"
  fi
  if [[ -f "$dir/docker-compose.yml" || -f "$dir/compose.yml" ]]; then
    tmux new-window -t "$session_name" -n docker -c "$dir"
  fi

  tmux select-window -t "$session_name:editor"
}

# ============================================
# Subcommands
# ============================================

# wt add <branch> [--base <ref>]
_wt_add() {
  local branch=""
  local base=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --base) base="$2"; shift 2 ;;
      *)      branch="$1"; shift ;;
    esac
  done

  if [[ -z "$branch" ]]; then
    echo "Usage: wt add <branch> [--base <ref>]"
    return 1
  fi

  local root
  root="$(_wt_main_root)"
  if [[ -z "$root" ]]; then
    return 1
  fi

  local safe_branch="${branch//\//-}"
  local wt_dir="${root}/.worktrees/${safe_branch}"

  if [[ -d "$wt_dir" ]]; then
    echo "wt: worktree already exists at ${wt_dir}"
  else
    if [[ -n "$base" ]]; then
      git worktree add -b "$branch" "$wt_dir" "$base"
    else
      # If branch already exists, just check it out; otherwise create it
      if git show-ref --verify --quiet "refs/heads/${branch}" 2>/dev/null; then
        git worktree add "$wt_dir" "$branch"
      else
        git worktree add -b "$branch" "$wt_dir"
      fi
    fi
  fi

  local session_name
  session_name="$(_wt_session_name "$branch")"
  _wt_create_session "$session_name" "$wt_dir"

  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "=$session_name"
  else
    tmux attach -t "=$session_name"
  fi
}

# wt ls
_wt_ls() {
  local root
  root="$(_wt_main_root)"
  if [[ -z "$root" ]]; then
    return 1
  fi

  local repo_name
  repo_name="$(basename "$root")"

  echo "Worktrees for ${repo_name}:"
  echo ""

  git worktree list | while IFS= read -r line; do
    local wt_path wt_branch
    wt_path="$(echo "$line" | awk '{print $1}')"
    wt_branch="$(echo "$line" | grep -oP '\[.*?\]' | tr -d '[]')"

    # Check tmux session status
    local session_name="${repo_name}/${wt_branch//\//-}"
    if tmux has-session -t "=$session_name" 2>/dev/null; then
      printf "  \033[32m●\033[0m %-50s %s \033[32m(tmux: active)\033[0m\n" "$wt_path" "[$wt_branch]"
    else
      printf "  \033[90m○\033[0m %-50s %s \033[90m(tmux: none)\033[0m\n" "$wt_path" "[$wt_branch]"
    fi
  done
}

# wt switch - fzf picker for worktree/session
_wt_switch() {
  local root
  root="$(_wt_main_root)"
  if [[ -z "$root" ]]; then
    return 1
  fi

  local repo_name
  repo_name="$(basename "$root")"

  local selected
  if command -v fzf &>/dev/null; then
    selected=$(git worktree list | awk 'NR>0 {print $0}' | \
      fzf --header="Switch worktree (${repo_name})" \
          --preview "
            dir=\$(echo {} | awk '{print \$1}')
            branch=\$(echo {} | grep -oP '\[.*?\]' | tr -d '[]')
            echo \"Branch: \$branch\"
            echo \"Path: \$dir\"
            echo ''
            echo '--- Recent commits ---'
            git -C \"\$dir\" log --oneline --graph --decorate -15 --color=always 2>/dev/null
          " \
          --preview-window=right:60%
    )
  else
    echo "Select worktree (${repo_name}):"
    local entries=()
    while IFS= read -r line; do
      entries+=("$line")
    done < <(git worktree list)
    local i
    for i in "${!entries[@]}"; do
      echo "  $((i + 1))) ${entries[$i]}"
    done
    local choice
    read -rp "Enter number: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#entries[@]} )); then
      selected="${entries[$((choice - 1))]}"
    fi
  fi

  if [[ -z "$selected" ]]; then
    return 0
  fi

  local wt_path wt_branch
  wt_path="$(echo "$selected" | awk '{print $1}')"
  wt_branch="$(echo "$selected" | grep -oP '\[.*?\]' | tr -d '[]')"

  local session_name="${repo_name}/${wt_branch//\//-}"

  # Create session if it doesn't exist
  _wt_create_session "$session_name" "$wt_path"

  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "=$session_name"
  else
    tmux attach -t "=$session_name"
  fi
}

# wt rm <branch>
_wt_rm() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "Usage: wt rm <branch>"
    return 1
  fi

  local root
  root="$(_wt_main_root)"
  if [[ -z "$root" ]]; then
    return 1
  fi

  local safe_branch="${branch//\//-}"
  local wt_dir="${root}/.worktrees/${safe_branch}"
  local session_name
  session_name="$(_wt_session_name "$branch")"

  # Check for uncommitted changes before removal
  if [[ -d "$wt_dir" ]] && git -C "$wt_dir" status --porcelain 2>/dev/null | grep -q .; then
    echo "wt: WARNING - worktree has uncommitted changes:"
    git -C "$wt_dir" status --short
    read -rp "Remove anyway? [y/N] " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
      echo "wt: aborted"
      return 1
    fi
  fi

  # Kill tmux session if it exists
  if tmux has-session -t "=$session_name" 2>/dev/null; then
    tmux kill-session -t "=$session_name"
    echo "wt: killed tmux session '${session_name}'"
  fi

  # Remove worktree
  if [[ -d "$wt_dir" ]]; then
    git worktree remove "$wt_dir"
    echo "wt: removed worktree '${wt_dir}'"
  else
    echo "wt: worktree not found at '${wt_dir}'"
    return 1
  fi

  # Offer to delete the branch
  if git show-ref --verify --quiet "refs/heads/${branch}" 2>/dev/null; then
    read -rp "Delete branch '${branch}'? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      git branch -d "$branch" 2>/dev/null || git branch -D "$branch"
      echo "wt: deleted branch '${branch}'"
    fi
  fi
}

# wt review <pr#>
_wt_review() {
  local pr_number="$1"
  if [[ -z "$pr_number" ]]; then
    echo "Usage: wt review <pr#>"
    return 1
  fi

  if ! command -v gh &>/dev/null; then
    echo "wt: gh CLI is required for review"
    return 1
  fi

  local branch
  branch=$(gh pr view "$pr_number" --json headRefName --jq '.headRefName' 2>/dev/null)
  if [[ -z "$branch" ]]; then
    echo "wt: could not find PR #${pr_number}"
    return 1
  fi

  echo "wt: PR #${pr_number} -> branch '${branch}'"

  # Fetch the branch
  git fetch origin "$branch" 2>/dev/null

  local root
  root="$(_wt_main_root)"
  local safe_branch="${branch//\//-}"
  local wt_dir="${root}/.worktrees/${safe_branch}"

  if [[ -d "$wt_dir" ]]; then
    echo "wt: worktree already exists, switching..."
  else
    git worktree add "$wt_dir" "origin/${branch}" 2>/dev/null || \
      git worktree add "$wt_dir" "$branch"
  fi

  local session_name
  session_name="$(_wt_session_name "$branch")"
  _wt_create_session "$session_name" "$wt_dir"

  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "=$session_name"
  else
    tmux attach -t "=$session_name"
  fi
}

# wt cd [branch] - cd into worktree directory
_wt_cd() {
  local branch="$1"
  local root
  root="$(_wt_main_root)"
  if [[ -z "$root" ]]; then
    return 1
  fi

  if [[ -n "$branch" ]]; then
    local safe_branch="${branch//\//-}"
    local wt_dir="${root}/.worktrees/${safe_branch}"
    if [[ -d "$wt_dir" ]]; then
      cd "$wt_dir" || return 1
    else
      echo "wt: worktree not found for branch '${branch}'"
      return 1
    fi
  else
    # Interactive picker
    local selected
    if command -v fzf &>/dev/null; then
      selected=$(git worktree list | \
        fzf --header="cd to worktree" \
            --preview "eza --color=always --icons --group-directories-first \$(echo {} | awk '{print \$1}') 2>/dev/null || ls -la \$(echo {} | awk '{print \$1}')"
      )
    else
      echo "Select worktree:"
      local entries=()
      while IFS= read -r line; do
        entries+=("$line")
      done < <(git worktree list)
      local i
      for i in "${!entries[@]}"; do
        echo "  $((i + 1))) ${entries[$i]}"
      done
      local choice
      read -rp "Enter number: " choice
      if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#entries[@]} )); then
        selected="${entries[$((choice - 1))]}"
      fi
    fi
    if [[ -n "$selected" ]]; then
      local wt_path
      wt_path="$(echo "$selected" | awk '{print $1}')"
      cd "$wt_path" || return 1
    fi
  fi
}

# wt help
_wt_help() {
  cat <<'EOF'
wt - Git Worktree + tmux integration

Usage: wt <command> [args]

Commands:
  add <branch> [--base <ref>]   Create worktree + tmux session
  ls                            List worktrees with tmux status
  switch                        fzf picker to switch worktree/session
  rm <branch>                   Remove worktree + kill tmux session
  review <pr#>                  Checkout PR branch as worktree
  cd [branch]                   cd into worktree (fzf if no arg)
  help                          Show this help

Worktree directory: <repo>/.worktrees/<branch-name>/
tmux session name:  <repo-name>/<branch>
Windows:            editor, claude, shell (+ server/docker if detected)

Examples:
  wt add feature/auth           # Create worktree + session
  wt add feature/api --base v2  # Create from specific ref
  wt switch                     # fzf pick and switch
  wt review 42                  # Review PR #42
  wt rm feature/auth            # Cleanup worktree + session
EOF
}

# ============================================
# Main Entry Point
# ============================================

wt() {
  if [[ $# -eq 0 ]]; then
    _wt_help
    return 0
  fi

  local subcmd="$1"
  shift

  case "$subcmd" in
    add)    _wt_add "$@" ;;
    ls)     _wt_ls ;;
    switch) _wt_switch ;;
    rm)     _wt_rm "$@" ;;
    review) _wt_review "$@" ;;
    cd)     _wt_cd "$@" ;;
    help)   _wt_help ;;
    *)
      echo "wt: unknown command '${subcmd}'"
      echo "Run 'wt help' for usage."
      return 1
      ;;
  esac
}

# ============================================
# Tab Completion
# ============================================

_wt_completions() {
  local cur prev subcmd
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ ${COMP_CWORD} -eq 1 ]]; then
    COMPREPLY=($(compgen -W "add ls switch rm review cd help" -- "$cur"))
    return
  fi

  subcmd="${COMP_WORDS[1]}"

  case "$subcmd" in
    add)
      # Complete branch names
      if [[ "$prev" == "--base" ]]; then
        local refs
        refs=$(git for-each-ref --format='%(refname:short)' refs/heads/ refs/tags/ 2>/dev/null)
        COMPREPLY=($(compgen -W "$refs" -- "$cur"))
      elif [[ "$cur" == --* ]]; then
        COMPREPLY=($(compgen -W "--base" -- "$cur"))
      else
        local branches
        branches=$(git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null)
        COMPREPLY=($(compgen -W "$branches" -- "$cur"))
      fi
      ;;
    rm|cd)
      # Complete existing worktree branches
      local wt_branches
      wt_branches=$(git worktree list 2>/dev/null | grep -oP '\[.*?\]' | tr -d '[]')
      COMPREPLY=($(compgen -W "$wt_branches" -- "$cur"))
      ;;
    review)
      # No completion for PR numbers
      ;;
  esac
}

complete -F _wt_completions wt

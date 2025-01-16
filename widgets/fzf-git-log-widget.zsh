# Git log search using fzf
fzf-git-log-widget() {
  local selected_commit
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    selected_commit=$(git log --oneline --color 2>/dev/null | fzf --preview 'git show --color=always --stat --patch {1}' --height 60% --preview-window=right:70% | awk '{print $1}')
  else
    selected_commit=""
  fi
  if [[ -n "$selected_commit" ]]; then
    LBUFFER="${LBUFFER}$selected_commit"
  fi
  zle redisplay
}

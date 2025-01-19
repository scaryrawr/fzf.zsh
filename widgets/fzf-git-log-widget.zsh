# Git log search using fzf
fzf-git-log-widget() {
  local selected_commits
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    selected_commits=$(git log --oneline --color 2>/dev/null | fzf --preview "$FZF_GIT_LOG_PREVIEW_CMD {1}" --height 60% --preview-window=right:60% --multi | awk '{print $1}' | tr '\n' ' ')
  else
    selected_commits=""
  fi
  if [[ -n "$selected_commits" ]]; then
    LBUFFER="${LBUFFER}$selected_commits"
  fi
  zle redisplay
}

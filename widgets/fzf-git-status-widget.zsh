# Git status search using fzf
fzf-git-status-widget() {
  local selected_files
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    selected_files=$(git status --short | fzf --preview "$FZF_GIT_STATUS_PREVIEW_CMD {}" --height 60% --preview-window=right:70% --multi | awk '{print $2}' | tr '\n' ' ')
  else
    selected_files=""
  fi
  if [[ -n "$selected_files" ]]; then
    LBUFFER="${LBUFFER}$selected_files"
  fi
  zle redisplay
}

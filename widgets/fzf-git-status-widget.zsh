# Git status search using fzf
fzf-git-status-widget() {
  local selected_file
  local preview_cmd=$FZF_PREVIEW_CMD
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    selected_file=$(git status --short | fzf --preview '[[ $(git ls-files --error-unmatch {2} 2>/dev/null) ]] && git diff --color=always {2} || (echo "Untracked:" && '"$preview_cmd"' {2})' --height 60% --preview-window=right:70% | awk '{print $2}')
  else
    selected_file=""
  fi
  if [[ -n "$selected_file" ]]; then
    LBUFFER="${LBUFFER}$selected_file"
  fi
  zle redisplay
}

0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

SCRIPT_DIR="$(dirname "$0")"

# Override for zsh integration
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

export FZF_DEFAULT_OPTS="--ansi"
export FZF_PREVIEW_CMD="${FZF_PREVIEW_CMD:-$SCRIPT_DIR/fzf_preview}"

fzf_find_files() {
  if command -v fd > /dev/null 2>&1; then
    fd --type file --color=always
  else
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
      find . -type f ! -path '*/.*' -print 2>/dev/null | grep -vFf <(git ls-files --others --ignored --exclude-standard --directory)
    else
      find . -type f ! -path '*/.*' -print 2>/dev/null
    fi
  fi
}

# File search using fzf
fzf-file-widget() {
  local selected_file
  local hint=""
  if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
    hint="${LBUFFER##* }"
  fi
  selected_file=$(fzf_find_files | fzf --preview "$FZF_PREVIEW_CMD {}" --height 60% --query="$hint")
  if [[ -n "$selected_file" ]]; then
    LBUFFER="${LBUFFER%$hint}$selected_file"
  fi
  zle redisplay
}

zle -N fzf-file-widget
bindkey '^T' fzf-file-widget

# History search using fzf
fzf-history-widget() {
  local selected_command
  local query="${BUFFER}"
  selected_command=$(fc -lnr 1 | fzf --height 60% --query="$query")
  if [[ -n "$selected_command" ]]; then
    BUFFER="$selected_command"
    CURSOR=${#BUFFER}  # Move cursor to the end of the buffer
  fi
  zle redisplay
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget
bindkey '^[[A' fzf-history-widget

# Directory search using fzf
fzf-cd-widget() {
  local selected_dir
  local hint="${LBUFFER}"
  BUFFER=
  selected_dir=$(fd --type d --color=always | fzf --preview "$FZF_PREVIEW_CMD {}" --height 60% --query="$hint")
  if [[ -n "$selected_dir" ]]; then
    cd "$selected_dir"
    zle accept-line
  fi
  zle reset-prompt
}

zle -N fzf-cd-widget
bindkey '^[c' fzf-cd-widget

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

zle -N fzf-git-log-widget
bindkey '^[^L' fzf-git-log-widget  # ctrl+alt+l

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

zle -N fzf-git-status-widget
bindkey '^[^T' fzf-git-status-widget  # ctrl+alt+t

fzf-variables-widget() {
  local selected_variable
  local hint=""
  if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
    hint="${LBUFFER##* }"
  fi
  selected_variable=$(env | fzf --height 60% --query="$hint" | awk -F'=' '{print $1}')
  if [[ -n "$selected_variable" ]]; then
    LBUFFER="${LBUFFER%$hint}\$$selected_variable"
  fi
  zle redisplay
}

zle -N fzf-variables-widget
bindkey '^V' fzf-variables-widget  # ctrl+shift+f

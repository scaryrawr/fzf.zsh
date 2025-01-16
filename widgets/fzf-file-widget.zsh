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

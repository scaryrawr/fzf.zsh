# History search using fzf
fzf-history-widget() {
  local query="${BUFFER}"
  local selected_command=$(fc -flnr 1 | awk '!seen[$0]++' | fzf --height 60% --preview="awk '{\$1=\"\"; \$2=\"\"; sub(/^ */, \"\"); print \$0}' <<< {}" --preview-window bottom:3:wrap --query="$query" | awk '{$1=""; $2=""; sub(/^ */, ""); print $0}')
  if [[ -n "$selected_command" ]]; then
    BUFFER="$selected_command"
    CURSOR=${#BUFFER}  # Move cursor to the end of the buffer
  fi
  zle redisplay
}
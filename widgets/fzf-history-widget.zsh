# History search using fzf
fzf-history-widget() {
  local selected_command
  local query="${BUFFER}"
  selected_command=$(fc -lnr 1 | awk '!seen[$0]++' | fzf --height 60% --query="$query")
  if [[ -n "$selected_command" ]]; then
    BUFFER="$selected_command"
    CURSOR=${#BUFFER}  # Move cursor to the end of the buffer
  fi
  zle redisplay
}

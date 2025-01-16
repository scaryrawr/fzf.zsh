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

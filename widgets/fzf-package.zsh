fzf-package-widget() {
  local selected_package
  local hint=""
  if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
    hint="${LBUFFER##* }"
  fi
  selected_package=$(find . -name 'package.json' -not -path '*/node_modules/*' -exec jq -r '.name' {} + | awk '!seen[$0]++' | fzf --height 60% --prompt="Select package: " --query="$hint")
  if [[ -n "$selected_package" ]]; then
    LBUFFER="${LBUFFER%$hint}$selected_package"
  fi
  zle redisplay
}

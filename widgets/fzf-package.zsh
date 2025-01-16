fzf-package-widget() {
  local selected_packages
  local hint=""
  if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
    hint="${LBUFFER##* }"
  fi
  selected_packages=$(find . -name 'package.json' -not -path '*/node_modules/*' -exec jq -r '.name' {} + | awk '!seen[$0]++' | fzf --height 60% --prompt="Select package(s): " --query="$hint" --multi | tr '\n' ' ')
  if [[ -n "$selected_packages" ]]; then
    LBUFFER="${LBUFFER%$hint}$selected_packages"
  fi
  zle redisplay
}

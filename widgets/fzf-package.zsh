fzf-package-widget() {
  local selected_packages
  local hint=""
  if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
    hint="${LBUFFER##* }"
  fi
  if command -v fd > /dev/null 2>&1; then
    selected_packages=$(fd -e json -E 'node_modules' -x jq -r '.name' {} | awk '!seen[$0]++' | fzf --height 60% --prompt="Select package(s): " --query="$hint" --multi | tr '\n' ' ')
  else
    selected_packages=$(find . -name 'package.json' -not -path '*/node_modules/*' -exec jq -r '.name' {} + | awk '!seen[$0]++' | fzf --height 60% --prompt="Select package(s): " --query="$hint" --multi | tr '\n' ' ')
  fi
  if [[ -n "$selected_packages" ]]; then
    LBUFFER="${LBUFFER%$hint}$selected_packages"
  fi
  zle redisplay
}

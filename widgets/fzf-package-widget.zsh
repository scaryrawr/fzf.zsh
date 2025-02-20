fzf-package-widget() {
  local selected_packages
  local hint=""
  if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
    hint="${LBUFFER##* }"
  fi

  if [[ ! -f "package.json" ]]; then
    return 1
  fi
  
  selected_packages=$(yarn --json workspaces info | jq -r '.data' | jq -r 'keys[]' | fzf --height 60% --prompt="Select package(s): " --preview "$FZF_PACKAGE_PREVIEW_CMD {}" --query="$hint" --multi | tr '\n' ' ')

  if [[ -n "$selected_packages" ]]; then
    LBUFFER="${LBUFFER%$hint}$selected_packages"
  fi
  zle redisplay
}

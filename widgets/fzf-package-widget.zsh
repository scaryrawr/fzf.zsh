fzf-package-widget() {
  local selected_packages
  local hint=""
  if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
    hint="${LBUFFER##* }"
  fi

  if [[ ! -f "package.json" ]]; then
    return 1
  fi
  
  # Begin caching logic similar to _monorepo_search_workspace.fish
  local safe_dir cache_dir mod_time cache_file packages_info
  safe_dir=${PWD//\//_}
  cache_dir="/tmp/fzf.zsh/$safe_dir"
  mkdir -p "$cache_dir"
  if [[ "$(uname)" == "Linux" ]]; then
    mod_time=$(stat --format=%Y .)
  else
    mod_time=$(stat -f %m .)
  fi
  cache_file="$cache_dir/$mod_time.json"
  
  if [[ -f "$cache_file" ]]; then
    packages_info=$(<"$cache_file")
  else
    packages_info=$(yarn --json workspaces info | jq -r '.data' | jq -r 'keys[]')
    echo "$packages_info" > "$cache_file"
  fi
  # End caching logic
  
  selected_packages=$(echo "$packages_info" | fzf --height 60% --prompt="Select package(s): " --preview "$FZF_PACKAGE_PREVIEW_CMD {}" --query="$hint" --multi | tr '\n' ' ')

  if [[ -n "$selected_packages" ]]; then
    LBUFFER="${LBUFFER%$hint}$selected_packages"
  fi
  zle redisplay
}

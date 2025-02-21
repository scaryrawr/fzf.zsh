fzf-package-widget() {
  local selected_packages
  local hint=""
  if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
    hint="${LBUFFER##* }"
  fi

  if [[ ! -f "package.json" ]]; then
    return 1
  fi
  
  safe_dir=${PWD//\//_}
  cache_dir="/tmp/fzf.zsh/$safe_dir"
  
  if [[ "$(uname)" == "Linux" ]]; then
    mod_time=$(stat --format=%Y .)
  else
    mod_time=$(stat -f %m .)
  fi

  cache_file="$cache_dir/$mod_time.json"
  if [[ -f "$cache_file" ]]; then
    packages_info=$(<"$cache_file")
  else
    mkdir -p "$cache_dir"
    packages_info=$(yarn --json workspaces info | jq -r '.data' | jq -r 'to_entries | map({name: .key, path: ("./" + .value.location + "/package.json")})' | tee "$cache_file")
  fi
  
  selected_packages=$(echo "$packages_info" | jq -r '.[].name' | fzf --height 60% --prompt="Select package(s): " --preview "$FZF_PACKAGE_PREVIEW_CMD {} '$cache_file'" --query="$hint" --multi | tr '\n' ' ')

  if [[ -n "$selected_packages" ]]; then
    LBUFFER="${LBUFFER%$hint}$selected_packages"
  fi
  zle redisplay
}

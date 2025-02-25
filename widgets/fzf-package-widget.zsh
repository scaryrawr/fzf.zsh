fzf-package-widget() {
  local hint=""
  if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
    hint="${LBUFFER##* }"
  fi

  if [[ ! -f "package.json" ]]; then
    return 1
  fi
  
  local safe_dir=${PWD//\//_}
  local cache_dir="/tmp/fzf.zsh/$safe_dir"
  local hash=$(git ls-files '*package.json' | xargs sha256sum | sha256sum | awk '{print $1}')

  local cache_file="$cache_dir/$hash.json"
  local packages_info
  if [[ -f "$cache_file" ]]; then
    packages_info=$(<"$cache_file")
  else
    mkdir -p "$cache_dir"
    packages_info=$(yarn --json workspaces info | jq -r '.data' | jq -r 'to_entries | map({name: .key, path: ("./" + .value.location + "/package.json")})' | tee "$cache_file")
  fi
  
  local selected_packages=$(echo "$packages_info" | jq -r '.[].name' | fzf --height 60% --prompt="Select package(s): " --preview "$FZF_PACKAGE_PREVIEW_CMD {} '$cache_file'" --query="$hint" --multi | tr '\n' ' ')

  if [[ -n "$selected_packages" ]]; then
    LBUFFER="${LBUFFER%$hint}$selected_packages"
  fi
  zle redisplay
}

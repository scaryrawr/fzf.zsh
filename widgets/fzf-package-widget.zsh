fzf-package-widget() {
	local hint=''
	if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
		hint="${LBUFFER##* }"
	fi

	local packages=$(rg --no-heading -N --glob 'package.json' '"name"' 2>/dev/null | sed -E 's|(.*):.*"name": *"([^"]+)".*|{"name":"\2","path":"\1"}|' | jq -s .)
	local crates=$(cargo metadata --format-version 1 2>/dev/null | jq -c '.packages | map(select(.id | startswith("path+file")) | {name: .name, path: .manifest_path})')

	packages=${packages:-'[]'}
	crates=${crates:-'[]'}
	local packages_info=$(echo "$packages" "$crates" | jq -s '.[0] + .[1]')

	local selected_packages=$(echo "$packages_info" | jq -r '.[].name' 2>/dev/null | awk '!seen[$0]++' | fzf --height 60% --prompt="Select package(s): " --preview "$FZF_PACKAGE_PREVIEW_CMD {} " --query="$hint" --multi | tr '\n' ' ')

	if [[ -n "$selected_packages" ]]; then
		LBUFFER="${LBUFFER%$hint}$selected_packages"
	fi
	zle redisplay
}

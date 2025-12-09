fzf-package-widget() {
	local hint=''
	if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
		hint="${LBUFFER##* }"
	fi

	local packages=$(rg --files --glob 'package.json' | xargs jq -r '.name + "\t" + input_filename')
	local crates=$(cargo metadata --format-version 1 2>/dev/null | jq -r '.packages | map(select(.id | startswith("path+file")) | .name + "\t" + .manifest_path) | .[]')

	packages=${packages:-''}
	crates=${crates:-''}
	local packages_info=$(printf '%s\n%s' "$packages" "$crates")

	local selected_packages=$(echo "$packages_info" | fzf --height 60% --prompt="Select package(s): " --preview "$FZF_PACKAGE_PREVIEW_CMD {1} {2}" --query="$hint" --multi --delimiter=$'\t' --with-nth=1 --bind="ctrl-o:execute(${EDITOR:-vim} {2})" | cut -d$'\t' -f1 | tr '\n' ' ')

	if [[ -n "$selected_packages" ]]; then
		LBUFFER="${LBUFFER%$hint}$selected_packages"
	fi
	zle redisplay
}

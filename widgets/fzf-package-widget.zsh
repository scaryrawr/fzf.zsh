fzf-package-widget() {
	local hint=''
	if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
		hint="${LBUFFER##* }"
	fi

	local selected_packages=$({
		rg --files --glob 'package.json' | xargs -r jq -r '.name + "\t" + input_filename' 2>/dev/null &
		cargo metadata --format-version 1 2>/dev/null | jq -r '.packages | map(select(.id | startswith("path+file")) | .name + "\t" + .manifest_path) | .[]' &
		wait
	} | fzf --height 60% --prompt="Select package(s): " --preview "$FZF_PACKAGE_PREVIEW_CMD {1} {2}" --query="$hint" --multi --delimiter=$'\t' --with-nth=1 --bind="ctrl-o:execute(${EDITOR:-vim} {2})" | cut -d$'\t' -f1 | tr '\n' ' ')

	if [[ -n "$selected_packages" ]]; then
		LBUFFER="${LBUFFER%$hint}$selected_packages"
	fi
	zle redisplay
}

fzf-package-widget() {
	local hint=''
	if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
		hint="${LBUFFER##* }"
	fi

	local packages_info='[]'
	if (( $+commands[rg] )) && (( $+commands[fd] )); then
		local packages=$(rg --no-heading --glob 'package.json' '"name"' | sed -E 's|(.*):.*"name": *"([^"]+)".*|{"name":"\2","path":"\1"}|' | jq -s .)
		local crates=$(fd -a Cargo.toml -x sh -c '
				name=$(grep -m1 "^name" "$1" | sed -E "s/name *= *\"([^\"]+)\"/\1/")
				[ -n "$name" ] && echo "{\"name\":\"$name\",\"path\":\"$1\"}"
			' sh {} | jq -s .)

		packages_info=$(echo "$packages" "$crates" | jq -s '.[0] + .[1]')
	elif git rev-parse --is-inside-work-tree &>/dev/null; then
		local packages=$(git ls-files --cached --others --exclude-standard '*package.json' | while read -r path; do
			name=$(grep -m1 '"name"' "$path" 2>/dev/null | sed -E 's/.*"name": *"([^"]+)".*/\1/')
			[ -n "$name" ] && echo "{\"name\":\"$name\",\"path\":\"$path\"}"
		done | jq -s .)

		local crates=$(git ls-files --cached --others --exclude-standard '*Cargo.toml' | while read -r path; do
			name=$(grep -m1 '^name' "$path" 2>/dev/null | sed -E 's/name *= *"([^"]+)".*/\1/')
			[ -n "$name" ] && echo "{\"name\":\"$name\",\"path\":\"$path\"}"
		done | jq -s .)

		packages_info=$(echo "$packages" "$crates" | jq -s '.[0] + .[1]')
	fi

	local selected_packages=$(echo "$packages_info" | jq -r '.[].name' | awk '!seen[$0]++' | fzf --height 60% --prompt="Select package(s): " --preview "$FZF_PACKAGE_PREVIEW_CMD {}" --query="$hint" --multi | tr '\n' ' ')

	if [[ -n "$selected_packages" ]]; then
		LBUFFER="${LBUFFER%$hint}$selected_packages"
	fi
	zle redisplay
}

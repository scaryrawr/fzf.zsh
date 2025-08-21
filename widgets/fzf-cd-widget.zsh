# Directory search using fzf
fzf-cd-widget() {
	local selected_dir
	local hint="${LBUFFER}"
	BUFFER=
	if command -v fd >/dev/null 2>&1; then
		selected_dir=$(fd --type d --color=always | fzf --preview "$FZF_PREVIEW_CMD {}" --height 60% --query="$hint")
	else
		selected_dir=$(find . -type d -not -path '*/\.*' -not -path '.' | sed 's|^\./||' | fzf --preview "$FZF_PREVIEW_CMD {}" --height 60% --query="$hint")
	fi
	if [[ -n "$selected_dir" ]]; then
		cd "$selected_dir"
		zle accept-line
	fi
	zle reset-prompt
}

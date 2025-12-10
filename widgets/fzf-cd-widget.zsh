# Directory search using fzf
fzf-cd-widget() {
	local selected_dir
	local hint="${LBUFFER}"
	selected_dir=$(fd $FZF_FD_OPTS --type d --color=always | fzf --preview "$FZF_PREVIEW_CMD {}" --height 60% --query="$hint")
	if [[ -n "$selected_dir" ]]; then
		cd "$selected_dir"
		zle accept-line
	fi
	zle reset-prompt
}

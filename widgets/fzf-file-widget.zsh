fzf_find_files() {
	fd $FZF_FD_OPTS --hidden --exclude .git --exclude .hg --exclude .svn --type file --color=always
}

# File search using fzf
fzf-file-widget() {
	local selected_files
	local hint=""
	if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
		hint="${LBUFFER##* }"
	fi
	selected_files=$(fzf_find_files | fzf --preview "$FZF_PREVIEW_CMD {}" --height 60% --preview-window=right:60% --query="$hint" --multi --bind="ctrl-o:execute(${EDITOR:-vim} {})" | tr '\n' ' ')
	if [[ -n "$selected_files" ]]; then
		LBUFFER="${LBUFFER%$hint}$selected_files"
	fi
	zle redisplay
}

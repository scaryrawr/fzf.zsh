# Live grep search using ripgrep + fzf
fzf-search-widget() {
	local selected
	local hint=""
	if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
		hint="${LBUFFER##* }"
	fi

	selected=$(
		: | fzf \
			--disabled \
			--query="$hint" \
			--prompt="Grep > " \
			--bind="start:reload:rg --color=always --line-number --column --smart-case -- {q} 2>/dev/null || true" \
			--bind="change:reload:sleep 0.1; rg --color=always --line-number --column --smart-case -- {q} 2>/dev/null || true" \
			--preview="$FZF_SEARCH_PREVIEW_CMD {}" \
			--height 60% \
			--preview-window=right:60% \
			--multi \
			--delimiter=":" \
			--bind="ctrl-o:execute(${EDITOR:-vim} {1} +{2})"
	)

	if [[ -n "$selected" ]]; then
		# Extract file:line pairs from selection
		local files=""
		while IFS= read -r line; do
			local file=$(echo "$line" | cut -d: -f1)
			local lineno=$(echo "$line" | cut -d: -f2)
			files+="${file}:${lineno} "
		done <<< "$selected"
		LBUFFER="${LBUFFER%$hint}${files% }"
	fi
	zle redisplay
}

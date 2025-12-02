fzf-git-blame-widget() {
	local commit
	while [[ -z "$commit" ]]; do
		local file=$(git ls-files | fzf --preview "$FZF_GIT_BLAME_PREVIEW_CMD {}" --height 60% --preview-window=right:70% --bind="ctrl-o:execute(${EDITOR:-vim} {})")
		[[ -n "$file" ]] || break

		local line=$(git blame --abbrev=8 "$file" | fzf --preview "$FZF_GIT_COMMIT_PREVIEW_CMD {1}" --height 60% --preview-window=right:70% | cut -c -80)
		[[ -n "$line" ]] || continue

		commit=$(echo "$line" | awk '{print $1}')
	done

	if [[ -n "$commit" ]]; then
		LBUFFER="${LBUFFER}$commit"
	fi

	zle redisplay
}

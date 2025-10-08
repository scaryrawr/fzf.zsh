fzf-variables-widget() {
	local hint=""
	if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
		hint="${LBUFFER##* }"
	fi
	local selected_variable=$(env | sort | awk -F'=' '{print $1}' | fzf --height 60% --preview 'env | awk -F= "/^{r}=/ {print \$2}"' --query="$hint" )
	if [[ -n "$selected_variable" ]]; then
		LBUFFER="${LBUFFER%$hint}\$$selected_variable"
	fi
	zle redisplay
}

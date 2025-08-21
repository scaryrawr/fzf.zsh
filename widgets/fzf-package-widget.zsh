fzf-package-widget() {
	local hint=''
	if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
		hint="${LBUFFER##* }"
	fi

	local safe_dir=${PWD//\//_}
	local cache_dir="/tmp/fzf.zsh/$safe_dir"

	local hash=''
	if [[ -f 'package.json' ]]; then
		hash=$(git ls-files '*package.json' | xargs sha256sum | sha256sum | awk '{print $1}')
	fi

	if [[ -f 'Cargo.toml' ]]; then
		local cargo_hash=$(git ls-files '*Cargo.toml' | xargs sha256sum | sha256sum | awk '{print $1}')
		local combine="${hash}-${cargo_hash}"
		hash=$(echo "$combine" | sha256sum | awk '{print $1}')
	fi

	if [[ -z "$hash" ]]; then
		return 1
	fi

	local cache_file="$cache_dir/$hash.json"
	local packages_info
	if [[ -f "$cache_file" ]]; then
		packages_info=$(<"$cache_file")
	else
		mkdir -p "$cache_dir"
		echo '[]' >"$cache_file"
		if [[ -f 'package.json' ]]; then
			if [[ -f 'yarn.lock' ]]; then
				local yarn_version=$(yarn --version 2>/dev/null | cut -d. -f1)
				if [[ "$yarn_version" == "1" ]]; then
					yarn --json workspaces info 2>/dev/null | jq -r '.data' | jq -r 'to_entries | map({name: .key, path: (.value.location + "/package.json")})' >"$cache_file"
				else
					yarn workspaces list --json 2>/dev/null | jq -s '[.[] | select(.location != ".") | {name: .name, path: (.location + "/package.json")}]' >"$cache_file"
				fi
			fi
		fi

		if [[ -f 'Cargo.toml' ]]; then
			cargo metadata --format-version 1 2>/dev/null | jq -r '.packages | map(select(.id | startswith("path+file")) | {name: .name, path: .manifest_path})' | jq -s '.[0] + .[1]' "$cache_file" - >"$cache_file.tmp"
			mv "$cache_file.tmp" "$cache_file"
		fi

		packages_info=$(<"$cache_file")
	fi

	local selected_packages=$(echo "$packages_info" | jq -r '.[].name' | awk '!seen[$0]++' | fzf --height 60% --prompt="Select package(s): " --preview "$FZF_PACKAGE_PREVIEW_CMD {} '$cache_file'" --query="$hint" --multi | tr '\n' ' ')

	if [[ -n "$selected_packages" ]]; then
		LBUFFER="${LBUFFER%$hint}$selected_packages"
	fi
	zle redisplay
}

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

		fzf_package_widget_handle_yarn "$cache_file"
		fzf_package_widget_handle_pnpm "$cache_file"
		fzf_package_widget_handle_bun "$cache_file"
		fzf_package_widget_handle_cargo "$cache_file"

		packages_info=$(<"$cache_file")
	fi

	local selected_packages=$(echo "$packages_info" | jq -r '.[].name' | awk '!seen[$0]++' | fzf --height 60% --prompt="Select package(s): " --preview "$FZF_PACKAGE_PREVIEW_CMD {} '$cache_file'" --query="$hint" --multi | tr '\n' ' ')

	if [[ -n "$selected_packages" ]]; then
		LBUFFER="${LBUFFER%$hint}$selected_packages"
	fi
	zle redisplay
}

fzf_package_widget_handle_bun() {
	local cache_file="$1"
	if [[ -f 'package.json' ]] && [[ -f 'bun.lock' ]]; then
		local workspaces
		workspaces=$(jq -r '.workspaces.packages[]?' package.json 2>/dev/null)
		if [[ -z "$workspaces" ]]; then
			workspaces=$(jq -r '.workspaces[]?' package.json 2>/dev/null)
		fi

		if [[ -n "$workspaces" ]]; then
			# Discover actual workspace package.json files from patterns and build JSON objects
			local packages_data=""
			while IFS= read -r pattern; do
				[[ -z "$pattern" ]] && continue
				while IFS= read -r pkg; do
					local name=$(jq -r .name "$pkg" 2>/dev/null)
					if [[ -n "$name" && "$name" != "null" ]]; then
						local obj=$(jq -n --arg name "$name" --arg path "$pkg" -c '{name: $name, path: $path}' 2>/dev/null)
						if [[ -z "$packages_data" ]]; then
							packages_data="$obj"
						else
							packages_data+=$'\n'"$obj"
						fi
					fi
				done < <(find . -path "./$pattern/package.json" -not -path "*/node_modules/*" -not -path "*/dist/*" -print 2>/dev/null)
			done <<<"$workspaces"

			if [[ -n "$packages_data" ]]; then
				# Merge Bun workspaces into existing cache
				local tmp_file="${cache_file}.tmp"
				printf '%s\n' "$packages_data" 2>/dev/null | jq -s '.' 2>/dev/null | jq -s '.[0] + .[1]' "$cache_file" - >"$tmp_file" 2>/dev/null && mv "$tmp_file" "$cache_file"
			fi
		fi
	fi
}

fzf_package_widget_handle_pnpm() {
	local cache_file="$1"
	# Use pnpm workspace info if present
	if [[ -f './pnpm-workspace.yaml' ]] && command -v pnpm >/dev/null 2>&1; then
		local tmp_file="${cache_file}.tmp"
		# List all workspace packages (excluding the root), then map to {name, path}
		local raw_output=$(pnpm list --recursive --depth -1 --json 2>/dev/null)
		if [[ -n "$raw_output" && "$raw_output" != "[]" ]]; then
			# Build relative ./path/package.json when under current pwd; otherwise keep absolute
			echo "$raw_output" |
				jq -c --arg pwd "$(pwd -P)" '
					[.[] |
					 select(.path != $pwd) |
					 {
					   name: .name,
					   path: (if (.path | startswith($pwd + "/")) then
					            "./" + (.path | sub($pwd + "/"; "")) + "/package.json"
					          else
					            .path + "/package.json"
					          end)
					 }
					]' 2>/dev/null |
				jq -s '.[0] + .[1]' "$cache_file" - >"$tmp_file" 2>/dev/null && mv "$tmp_file" "$cache_file"
		fi
	fi
}

fzf_package_widget_handle_yarn() {
	local cache_file="$1"
	if [[ -f 'package.json' ]] && [[ -f 'yarn.lock' ]]; then
		local yarn_version=$(yarn --version 2>/dev/null | cut -d. -f1)
		local tmp_file="${cache_file}.tmp"
		if [[ "$yarn_version" == "1" ]]; then
			# Merge Yarn v1 workspaces into existing cache
			yarn --json workspaces info 2>/dev/null |
				jq -r '.data' 2>/dev/null |
				jq -c 'to_entries | map({name: .key, path: (.value.location + "/package.json")})' 2>/dev/null |
				jq -s '.[0] + .[1]' "$cache_file" - >"$tmp_file" 2>/dev/null && mv "$tmp_file" "$cache_file"
		else
			# Merge Yarn Berry (v2+) workspaces into existing cache
			yarn workspaces list --json 2>/dev/null |
				jq -s '[.[] | select(.location != ".") | {name: .name, path: (.location + "/package.json")}]' 2>/dev/null |
				jq -s '.[0] + .[1]' "$cache_file" - >"$tmp_file" 2>/dev/null && mv "$tmp_file" "$cache_file"
		fi
	fi
}

fzf_package_widget_handle_cargo() {
	local cache_file="$1"
	if [[ -f 'Cargo.toml' ]]; then
		cargo metadata --format-version 1 2>/dev/null | jq -c '.packages | map(select(.id | startswith("path+file")) | {name: .name, path: .manifest_path})' 2>/dev/null | jq -s '.[0] + .[1]' "$cache_file" - >"$cache_file.tmp" 2>/dev/null
		mv "$cache_file.tmp" "$cache_file"
	fi
}

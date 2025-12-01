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

		fzf_package_widget_handle_npm_workspaces "$cache_file"
		fzf_package_widget_handle_pnpm "$cache_file"
		fzf_package_widget_handle_cargo "$cache_file"

		packages_info=$(<"$cache_file")
	fi

	local selected_packages=$(echo "$packages_info" | jq -r '.[].name' | awk '!seen[$0]++' | fzf --height 60% --prompt="Select package(s): " --preview "$FZF_PACKAGE_PREVIEW_CMD {} '$cache_file'" --query="$hint" --multi | tr '\n' ' ')

	if [[ -n "$selected_packages" ]]; then
		LBUFFER="${LBUFFER%$hint}$selected_packages"
	fi
	zle redisplay
}

# Shared helper: discover packages from workspace patterns using fd/find
_fzf_package_widget_find_packages() {
	local cache_file="$1"
	local workspaces="$2"

	[[ -n "$workspaces" ]] || return 0

	# Build list of directories to search from patterns
	local search_dirs=()
	while IFS= read -r pattern; do
		[[ -z "$pattern" ]] && continue
		[[ "$pattern" == !* ]] && continue  # Skip negation patterns
		# Extract directory from pattern (e.g., "packages/*" -> "packages")
		local dir="${pattern%%/*}"
		[[ -d "$dir" ]] && search_dirs+=("$dir")
	done <<<"$workspaces"

	[[ ${#search_dirs[@]} -eq 0 ]] && return 0

	# Use fd if available (faster), otherwise fall back to find
	local package_files
	if (( $+commands[fd] )); then
		package_files=$(fd -t f -H package.json "${search_dirs[@]}" 2>/dev/null)
	else
		package_files=$(find "${search_dirs[@]}" -name package.json -not -path "*/node_modules/*" -not -path "*/dist/*" 2>/dev/null)
	fi

	[[ -n "$package_files" ]] || return 0

	# Process files with jq in batch
	local tmp_file="${cache_file}.tmp"
	echo "$package_files" | xargs jq -c '{name: .name, path: input_filename}' 2>/dev/null | 
		jq -s '.' 2>/dev/null | 
		jq -s '.[0] + .[1]' "$cache_file" - >"$tmp_file" 2>/dev/null && mv "$tmp_file" "$cache_file"
}

fzf_package_widget_handle_pnpm() {
	local cache_file="$1"
	[[ -f './pnpm-workspace.yaml' ]] || return 0

	# Try fd/find first (faster and doesn't require pnpm)
	local workspaces
	if (( $+commands[yq] )); then
		workspaces=$(yq -r '.packages[]?' './pnpm-workspace.yaml' 2>/dev/null)
	else
		# Fallback: simple grep for lines starting with "  - " under packages
		workspaces=$(grep -E "^\s+-\s+['\"]?[^'\"]+['\"]?\s*$" './pnpm-workspace.yaml' 2>/dev/null | sed "s/^[[:space:]]*-[[:space:]]*['\"]\\{0,1\\}\\([^'\"]*\\)['\"]\\{0,1\\}[[:space:]]*$/\\1/")
	fi

	if [[ -n "$workspaces" ]]; then
		_fzf_package_widget_find_packages "$cache_file" "$workspaces"
		return $?
	fi

	# Fall back to pnpm command if available
	(( $+commands[pnpm] )) || return 0

	local tmp_file="${cache_file}.tmp"
	local raw_output=$(pnpm list --recursive --depth -1 --json 2>/dev/null)
	[[ -n "$raw_output" && "$raw_output" != "[]" ]] || return 0

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
}

fzf_package_widget_handle_npm_workspaces() {
	local cache_file="$1"
	[[ -f 'package.json' ]] || return 0
	[[ -f 'pnpm-workspace.yaml' ]] && return 0  # Skip if pnpm workspace (handled by pnpm handler)

	# Try yarn command first if available (fastest for workspaces, works for yarn/bun/npm)
	if (( $+commands[yarn] )); then
		local yarn_version=$(yarn --version 2>/dev/null | cut -d. -f1)
		local tmp_file="${cache_file}.tmp"
		if [[ "$yarn_version" == "1" ]]; then
			# Merge Yarn v1 workspaces into existing cache
			yarn --json workspaces info 2>/dev/null |
				jq -r '.data' 2>/dev/null |
				jq -c 'to_entries | map({name: .key, path: (.value.location + "/package.json")})' 2>/dev/null |
				jq -s '.[0] + .[1]' "$cache_file" - >"$tmp_file" 2>/dev/null && mv "$tmp_file" "$cache_file"
			return $?
		else
			# Merge Yarn Berry (v2+) workspaces into existing cache
			yarn workspaces list --json 2>/dev/null |
				jq -s '[.[] | select(.location != ".") | {name: .name, path: (.location + "/package.json")}]' 2>/dev/null |
				jq -s '.[0] + .[1]' "$cache_file" - >"$tmp_file" 2>/dev/null && mv "$tmp_file" "$cache_file"
			return $?
		fi
	fi

	# Fall back to parsing package.json and using fd/find
	local workspaces
	workspaces=$(jq -r '.workspaces.packages[]?' package.json 2>/dev/null)
	if [[ -z "$workspaces" ]]; then
		workspaces=$(jq -r '.workspaces[]?' package.json 2>/dev/null)
	fi

	_fzf_package_widget_find_packages "$cache_file" "$workspaces"
}

fzf_package_widget_handle_cargo() {
	local cache_file="$1"
	[[ -f 'Cargo.toml' ]] || return 0
	(( $+commands[cargo] )) || return 0

	cargo metadata --format-version 1 2>/dev/null | jq -c '.packages | map(select(.id | startswith("path+file")) | {name: .name, path: .manifest_path})' 2>/dev/null | jq -s '.[0] + .[1]' "$cache_file" - >"$cache_file.tmp" 2>/dev/null
	mv "$cache_file.tmp" "$cache_file"
}

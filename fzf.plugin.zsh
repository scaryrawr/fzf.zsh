# These two lines recompute $0 to the absolute path of this file when sourced.
# Wrap in eval so shfmt doesn't attempt to parse zsh-only expansions.
eval '0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"; 0="${${(M)0:#/*}:-$PWD/$0}"'

FZF_PLUGIN_DIR="$(dirname "$0")"

# ------------------------------------------------------------------------------
# Dependency check
# ------------------------------------------------------------------------------
if ! command -v fzf &>/dev/null; then
	echo "fzf plugin: fzf not found. Please install fzf to use this plugin." >&2
	return 1
fi

# ------------------------------------------------------------------------------
# Default options (can be overridden before sourcing)
# ------------------------------------------------------------------------------
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---ansi --cycle --layout=reverse --border --height=90% --preview-window=wrap}"

# ------------------------------------------------------------------------------
# Auto-export preview commands from previewers directory
# Converts fzf_git_blame_preview -> FZF_GIT_BLAME_PREVIEW_CMD
# ------------------------------------------------------------------------------
for previewer in "$FZF_PLUGIN_DIR"/previewers/fzf_*; do
	[[ -f "$previewer" ]] || continue
	name="${previewer:t}"                                # basename: fzf_git_blame_preview
	var_name="${(U)name}_CMD"                            # uppercase: FZF_GIT_BLAME_PREVIEW_CMD
	export "${var_name}=${(P)var_name:-$previewer}"      # export if not already set
done

# Special case: delta for diffs
export FZF_DIFF_PREVIEW_CMD="${FZF_DIFF_PREVIEW_CMD}"
if [[ -z "$FZF_DIFF_PREVIEW_CMD" ]] && command -v delta &>/dev/null; then
	export FZF_DIFF_PREVIEW_CMD="delta --paging=never"
fi

# ------------------------------------------------------------------------------
# Default key bindings (can be overridden in FZF_KEYBINDINGS associative array)
# ------------------------------------------------------------------------------
# Create a global associative array for keybindings.
# To override keybindings in your .zshrc, use the same declaration:
# typeset -gA FZF_KEYBINDINGS
typeset -gA FZF_KEYBINDINGS
: ${FZF_KEYBINDINGS[fzf-file-widget]:='^[^F'}
: ${FZF_KEYBINDINGS[fzf-history-widget]:='^R'}
: ${FZF_KEYBINDINGS[fzf-cd-widget]:='^[c'}
: ${FZF_KEYBINDINGS[fzf-git-log-widget]:='^[^L'}
: ${FZF_KEYBINDINGS[fzf-git-status-widget]:='^[^S'}
: ${FZF_KEYBINDINGS[fzf-variables-widget]:='^V'}
: ${FZF_KEYBINDINGS[fzf-package-widget]:='^[^W'}
: ${FZF_KEYBINDINGS[fzf-git-blame-widget]:='^[^B'}

# ------------------------------------------------------------------------------
# Auto-discover, source, register, and bind widgets
# ------------------------------------------------------------------------------
for widget_file in "$FZF_PLUGIN_DIR"/widgets/fzf-*-widget.zsh; do
	[[ -f "$widget_file" ]] || continue

	# Source the widget file
	source "$widget_file"

	# Extract widget name from filename: fzf-file-widget.zsh -> fzf-file-widget
	widget_name="${${widget_file:t}%.zsh}"

	# Register as ZLE widget
	zle -N "$widget_name"

	# Bind key if configured
	# If keybind is an empty string, the widget is "disabled" (i.e., not bound to any key).
	# This matches the documented behavior: setting an empty string disables the widget.
	keybind="${FZF_KEYBINDINGS[$widget_name]}"
	if [[ -n "$keybind" ]]; then
		bindkey "$keybind" "$widget_name"
	fi
done

# These two lines recompute $0 to the absolute path of this file when sourced.
# Wrap in eval so shfmt doesn't attempt to parse zsh-only expansions.
eval '0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"; 0="${${(M)0:#/*}:-$PWD/$0}"'

SCRIPT_DIR="$(dirname "$0")"

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---ansi --cycle --layout=reverse --border --height=90% --preview-window=wrap}"

export FZF_PREVIEW_CMD="${FZF_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_preview}"
export FZF_GIT_BLAME_PREVIEW_CMD="${FZF_GIT_BLAME_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_git_blame_preview}"
export FZF_GIT_COMMIT_PREVIEW_CMD="${FZF_GIT_COMMIT_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_git_commit_preview}"
export FZF_GIT_LOG_PREVIEW_CMD="${FZF_GIT_LOG_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_git_log_preview}"
export FZF_GIT_STATUS_PREVIEW_CMD="${FZF_GIT_STATUS_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_git_status_preview}"
export FZF_PACKAGE_PREVIEW_CMD="${FZF_PACKAGE_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_package_preview}"
export FZF_DIFF_PREVIEW_CMD="${FZF_DIFF_PREVIEW_CMD}"

if [[ -z "$FZF_DIFF_PREVIEW_CMD" ]] && command -v delta &>/dev/null; then
	export FZF_DIFF_PREVIEW_CMD="delta --paging=never"
fi

# Source all widget files
source "$SCRIPT_DIR/widgets/fzf-file-widget.zsh"
source "$SCRIPT_DIR/widgets/fzf-history-widget.zsh"
source "$SCRIPT_DIR/widgets/fzf-cd-widget.zsh"
source "$SCRIPT_DIR/widgets/fzf-git-log-widget.zsh"
source "$SCRIPT_DIR/widgets/fzf-git-status-widget.zsh"
source "$SCRIPT_DIR/widgets/fzf-variables-widget.zsh"
source "$SCRIPT_DIR/widgets/fzf-package-widget.zsh"
source "$SCRIPT_DIR/widgets/fzf-git-blame-widget.zsh"

# Register widgets
zle -N fzf-file-widget
zle -N fzf-history-widget
zle -N fzf-cd-widget
zle -N fzf-git-log-widget
zle -N fzf-git-status-widget
zle -N fzf-variables-widget
zle -N fzf-package-widget
zle -N fzf-git-blame-widget

# Key bindings
bindkey '^T' fzf-file-widget
bindkey '^[^F' fzf-file-widget
bindkey '^R' fzf-history-widget
bindkey '^[c' fzf-cd-widget
bindkey '^[^L' fzf-git-log-widget
bindkey '^[^T' fzf-git-status-widget
bindkey '^[^S' fzf-git-status-widget
bindkey '^V' fzf-variables-widget
bindkey '^[^P' fzf-package-widget
bindkey '^[^W' fzf-package-widget
bindkey '^[^B' fzf-git-blame-widget

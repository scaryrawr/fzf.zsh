0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

SCRIPT_DIR="$(dirname "$0")"

# Override for zsh integration
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

export FZF_DEFAULT_OPTS="--ansi"

export FZF_PREVIEW_CMD="${FZF_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_preview}"
export FZF_GIT_BLAME_PREVIEW_CMD="${FZF_GIT_BLAME_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_git_blame_preview}"
export FZF_GIT_COMMIT_PREVIEW_CMD="${FZF_GIT_COMMIT_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_git_commit_preview}"
export FZF_GIT_LOG_PREVIEW_CMD="${FZF_GIT_LOG_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_git_log_preview}"
export FZF_GIT_STATUS_PREVIEW_CMD="${FZF_GIT_STATUS_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_git_status_preview}"
export FZF_PACKAGE_PREVIEW_CMD="${FZF_PACKAGE_PREVIEW_CMD:-$SCRIPT_DIR/previewers/fzf_package_preview}"
export FZF_DIFF_PREVIEW_CMD="${FZF_DIFF_PREVIEW_CMD}"
if [[ -z "$FZF_DIFF_PREVIEW_CMD" ]] && command -v delta &> /dev/null; then
  export FZF_DIFF_PREVIEW_CMD="delta --paging=never"
fi

# Lazy load widget functions
lazy_load_widget() {
  local widget_file="$1"
  local widget_name="$2"
  source "$SCRIPT_DIR/widgets/$widget_file"
  zle -N "$widget_name"
  zle "$widget_name"
}

bindkey '^T' lazy-load-fzf-file-widget
zle -N lazy-load-fzf-file-widget
lazy-load-fzf-file-widget() { lazy_load_widget "fzf-file-widget.zsh" "fzf-file-widget"; }

bindkey '^R' lazy-load-fzf-history-widget
bindkey '^[[A' lazy-load-fzf-history-widget
zle -N lazy-load-fzf-history-widget
lazy-load-fzf-history-widget() { lazy_load_widget "fzf-history-widget.zsh" "fzf-history-widget"; }

bindkey '^[c' lazy-load-fzf-cd-widget
zle -N lazy-load-fzf-cd-widget
lazy-load-fzf-cd-widget() { lazy_load_widget "fzf-cd-widget.zsh" "fzf-cd-widget"; }

bindkey '^[^L' lazy-load-fzf-git-log-widget
zle -N lazy-load-fzf-git-log-widget
lazy-load-fzf-git-log-widget() { lazy_load_widget "fzf-git-log-widget.zsh" "fzf-git-log-widget"; }

bindkey '^[^T' lazy-load-fzf-git-status-widget
zle -N lazy-load-fzf-git-status-widget
lazy-load-fzf-git-status-widget() { lazy_load_widget "fzf-git-status-widget.zsh" "fzf-git-status-widget"; }

bindkey '^V' lazy-load-fzf-variables-widget
zle -N lazy-load-fzf-variables-widget
lazy-load-fzf-variables-widget() { lazy_load_widget "fzf-variables-widget.zsh" "fzf-variables-widget"; }

bindkey '^[^P' lazy-load-fzf-package-widget
zle -N lazy-load-fzf-package-widget
lazy-load-fzf-package-widget() { lazy_load_widget "fzf-package-widget.zsh" "fzf-package-widget"; }

bindkey '^[^B' lazy-load-fzf-git-blame-widget
zle -N lazy-load-fzf-git-blame-widget
lazy-load-fzf-git-blame-widget() { lazy_load_widget "fzf-git-blame-widget.zsh" "fzf-git-blame-widget"; }

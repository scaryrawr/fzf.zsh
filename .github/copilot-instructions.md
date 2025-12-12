# Copilot Instructions for fzf.zsh

A zsh plugin providing fzf-powered widgets for file search, git operations, and more.

## Architecture

- **[fzf.plugin.zsh](../fzf.plugin.zsh)**: Main entry point that auto-discovers widgets and previewers
- **[widgets/](../widgets/)**: ZLE widgets (shell functions bound to keybindings)
- **[previewers/](../previewers/)**: Executable preview scripts called by fzf

### Auto-discovery Pattern

The plugin automatically:

1. Sources all `widgets/fzf-*-widget.zsh` files
2. Registers them as ZLE widgets and binds keys via `FZF_KEYBINDINGS`
3. Exports previewer scripts as `FZF_*_PREVIEW_CMD` environment variables (e.g., `fzf_git_blame_preview` → `FZF_GIT_BLAME_PREVIEW_CMD`)

## Adding New Widgets

Create `widgets/fzf-<name>-widget.zsh` with a function matching the filename:

```zsh
fzf-<name>-widget() {
    local selected=$(your-command | fzf --preview "$FZF_<NAME>_PREVIEW_CMD {}")
    if [[ -n "$selected" ]]; then
        LBUFFER="${LBUFFER}$selected"
    fi
    zle redisplay
}
```

Add default keybinding in `fzf.plugin.zsh`:

```zsh
(( ! ${+FZF_KEYBINDINGS[fzf-<name>-widget]} )) && FZF_KEYBINDINGS[fzf-<name>-widget]='^[^X'
```

## Adding New Previewers

Create executable script in `previewers/fzf_<name>_preview` (no extension). Use bash, not zsh:

```bash
#!/usr/bin/env bash
input="$1"
# Preview logic here
```

## Coding Conventions

- **Widgets**: Written in zsh, use `LBUFFER`/`BUFFER` for line manipulation, call `zle redisplay` or `zle reset-prompt`
- **Previewers**: Written in bash with `#!/usr/bin/env bash`, receive fzf selection as `$1`
- **Optional dependencies**: Check with `command -v` before using (bat, eza, chafa, delta)
- **User customization**: Use `${VAR:-default}` pattern so users can override via environment variables
- **fd integration**: Pass `$FZF_FD_OPTS` to fd commands for user-configurable search options

## Key Patterns

### Widget hint extraction (pre-fill fzf query from cursor context):

```zsh
local hint=""
if [[ "$LBUFFER" =~ [^[:space:]]$ ]]; then
    hint="${LBUFFER##* }"
fi
```

### Multi-select with editor binding:

```zsh
fzf --multi --bind="ctrl-o:execute(${EDITOR:-vim} {})"
```

### Preview with bat fallback:

```bash
if command -v bat >/dev/null 2>&1; then
    bat --style=numbers --color=always "$file"
else
    cat "$file"
fi
```

## Dependencies

Required: `fzf`, `fd`, `rg` (ripgrep)  
Optional: `bat`, `eza`, `chafa`, `delta`

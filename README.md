# FZF ZSH Plugin

This is a plugin for zsh heavily inspired by [PatrickF1/fzf.fish](https://github.com/PatrickF1/fzf.fish).

It's still a work in progress, and has slightly different keybindings.

## Keybindings

For git status to work with `Ctrl+Alt+S`, make sure to disable `ixon` in your `.zshrc`:

```zsh
if [[ $- == *i* ]]; then
  stty -ixon < /dev/tty
fi
```

| Keybinding   | Description                            |
| ------------ | -------------------------------------- |
| `Ctrl+Alt+F` | File search using fzf                  |
| `Ctrl+R`     | History search using fzf               |
| `Alt+c`      | Change directory using fzf             |
| `Ctrl+Alt+L` | Git log search using fzf               |
| `Ctrl+Alt+S` | Git status search using fzf            |
| `Ctrl+V`     | Environment variables search using fzf |
| `Ctrl+Alt+W` | Find a package name using fzf          |
| `Ctrl+Alt+B` | Blame search                           |

## Installation

### Antidote

```sh
antidote install scaryrawr/fzf.zsh
```

### Oh My Zsh

```sh
git clone https://github.com/scaryrawr/fzf.zsh $ZSH_CUSTOM/plugins/fzf
```

## Screenshots

### File Search

![File Search](assets/file_search.png)

![Image Preview](assets/image_preview.png)

### History Search

![History Search](assets/history_search.png)

### Change Directory

![Change Directory](assets/change_directory.png)

### Git Log Search

![Git Log Search](assets/git_log_search.png)

### Git Status Search

![Git Status Search](assets/git_status_search.png)

### Environment Variables Search

![Environment Variables Search](assets/env_vars_search.png)

### Find a Package Name

![Find a Package Name](assets/find_package_name.png)

## Dependencies

### Required

- [fzf](https://github.com/junegunn/fzf)

### Optional

- [chafa](https://github.com/hpjansson/chafa) - Image preview
- [bat](https://github.com/sharkdp/bat) - cat with syntax highlighting
- [fd](https://github.com/sharkdp/fd) - Alternative to `find`
- [eza](https://github.com/eza-community/eza) - Alternative to `ls`

## Customizable Variables

You can customize the behavior of the fzf plugin by setting the following environment variables:

| Variable Name                | Description                           | Passed Argument |
| ---------------------------- | ------------------------------------- | --------------- |
| `FZF_DEFAULT_OPTS`           | Default options for fzf               | N/A             |
| `FZF_PREVIEW_CMD`            | Command to use for file preview       | file path       |
| `FZF_GIT_BLAME_PREVIEW_CMD`  | Command to use for git blame preview  | file path       |
| `FZF_GIT_COMMIT_PREVIEW_CMD` | Command to use for git commit preview | commit          |
| `FZF_GIT_LOG_PREVIEW_CMD`    | Command to use for git log preview    | commit          |
| `FZF_DIFF_PREVIEW_CMD`       | Command to use for diff preview       | diff            |

## Custom Keybindings

You can override the default keybindings using the `FZF_KEYBINDINGS` associative array **before** sourcing the plugin:

```zsh
# In your .zshrc, before loading the plugin:
typeset -gA FZF_KEYBINDINGS
FZF_KEYBINDINGS[fzf-file-widget]='^F'        # Change file widget to Ctrl+F
FZF_KEYBINDINGS[fzf-history-widget]='^H'     # Change history widget to Ctrl+H
FZF_KEYBINDINGS[fzf-cd-widget]=''            # Disable cd widget (empty string)
```

### Available Widgets

| Widget Name             | Default Keybinding | Description                            |
| ----------------------- | ------------------ | -------------------------------------- |
| `fzf-file-widget`       | `^[^F`             | File search using fzf                  |
| `fzf-history-widget`    | `^R`               | History search using fzf               |
| `fzf-cd-widget`         | `^[c`              | Change directory using fzf             |
| `fzf-git-log-widget`    | `^[^L`             | Git log search using fzf               |
| `fzf-git-status-widget` | `^[^S`             | Git status search using fzf            |
| `fzf-variables-widget`  | `^V`               | Environment variables search using fzf |
| `fzf-package-widget`    | `^[^W`             | Find a package name using fzf          |
| `fzf-git-blame-widget`  | `^[^B`             | Blame search                           |

### Keybinding Notation

| Notation | Meaning  |
| -------- | -------- |
| `^`      | Ctrl     |
| `^[`     | Alt/Meta |
| `^[^`    | Ctrl+Alt |

## Adding Custom Widgets

To add a new widget, create a file in the `widgets/` directory following the naming convention `fzf-<name>-widget.zsh`. The plugin will automatically:

1. Source the widget file
2. Register it as a ZLE widget
3. Bind it to a key (if configured in `FZF_KEYBINDINGS`)

Example widget file (`widgets/fzf-custom-widget.zsh`):

```zsh
fzf-custom-widget() {
    local selected=$(your-command | fzf)
    if [[ -n "$selected" ]]; then
        LBUFFER="${LBUFFER}$selected"
    fi
    zle redisplay
}
```

Then add a keybinding before sourcing the plugin:

```zsh
typeset -gA FZF_KEYBINDINGS
FZF_KEYBINDINGS[fzf-custom-widget]='^[^X'  # Alt+Ctrl+X
```

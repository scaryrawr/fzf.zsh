# FZF ZSH Plugin

This is a plugin for zsh heavily inspired by [PatrickF1/fzf.fish](https://github.com/PatrickF1/fzf.fish).

It's still a work in progress, and has slightly different keybindings.

## Keybindings

| Keybinding   | Description                            |
| ------------ | -------------------------------------- |
| `Ctrl+T`     | File search using fzf                  |
| `Ctrl+R`     | History search using fzf               |
| `Alt+c`      | Change directory using fzf             |
| `Ctrl+Alt+L` | Git log search using fzf               |
| `Ctrl+Alt+T` | Git status search using fzf            |
| `Ctrl+V`     | Environment variables search using fzf |
| `Ctrl+Alt+P` | Find a package name using fzf          |

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

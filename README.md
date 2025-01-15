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

## Dependencies

### Required

- [fzf](https://github.com/junegunn/fzf)

### Optional

- [chafa](https://github.com/hpjansson/chafa) - Image preview
- [bat](https://github.com/sharkdp/bat) - cat with syntax highlighting
- [fd](https://github.com/sharkdp/fd) - Alternative to `find`
- [eza](https://github.com/eza-community/eza) - Alternative to `ls`

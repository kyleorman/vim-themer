/**********************************************************/
/*  _   _                                    _            */
/* | |_| |__   ___ _ __ ___   ___ _ ____   _(_)_ __ ___   */
/* | __| '_ \ / _ \ '_ ` _ \ / _ \ '__\ \ / / | '_ ` _ \  */
/* | |_| | | |  __/ | | | | |  __/ | _ \ V /| | | | | | | */
/*  \__|_| |_|\___|_| |_| |_|\___|_|(_) \_/ |_|_| |_| |_| */
/*                                                        */
/**********************************************************/


A Vim plugin for seamless colorscheme management with FZF integration and pywal support. themer.vim provides an intuitive interface for selecting, applying, and managing colorschemes, including support for pywal-generated themes.

## Features

- 🎨 FZF-powered colorscheme selector
- 🔄 Pywal integration for system-wide color consistency
- 💾 Theme persistence across sessions
- ⚡ Quick theme switching with customizable keybindings
- 🌓 Automatic dark/light mode detection
- 🎯 Support for multiple colorscheme directories

## Installation

### Requirements

- Vim 8.0+ with Python support
- [FZF](https://github.com/junegunn/fzf) (for colorscheme selection)
- [pywal](https://github.com/dylanaraps/pywal) (optional, for pywal integration)

### Using a Plugin Manager

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'junegunn/fzf'  " Required dependency
Plug 'kyleorman/vim-themer'
```

## Configuration

Add these settings to your `vimrc` to customize themer.vim's behavior:

```vim
" Default settings shown below
let g:vim_themer_dirs = ['~/.vim/pack/colors/start']  " Colorscheme directories
let g:vim_themer_mode = "manual"                      " Options: 'manual', 'pywal'
let g:vim_themer_background = "auto"                  " Options: 'light', 'dark', 'auto'
let g:vim_themer_silent = 0                           " Options: 0 (verbose), 1 (silent)

" Optional: Disable default keybindings
let g:vim_themer_disable_keybindings = 0

" Optional: Customize keybindings
let g:vim_themer_keymap_theme_select = '<leader>tt'   " Themer Theme - Fuzzy find themes
let g:vim_themer_keymap_pywal = '<leader>tp'         " Themer Pywal - Loads the current pywal color scheme
let g:vim_themer_keymap_save_theme = '<leader>ts'    " Themer Save - Saves currently applied theme
```

## Commands

themer.vim provides the following commands:

| Command | Description | Default Keybinding |
|---------|-------------|-------------------|
| `:ThemeSelect` | Open FZF theme selector | `<leader>tt` |
| `:PywalTheme` | Apply pywal colorscheme | `<leader>tp` |
| `:SaveTheme` | Save current theme as default | `<leader>ts` |

## Usage

### Basic Theme Selection

1. Press `<leader>tt` or run `:ThemeSelect` to open the FZF theme selector
2. Search and select a theme using FZF's fuzzy finding
3. The selected theme will be applied immediately

### Pywal Integration

1. First, generate a color scheme using pywal: `wal -i /path/to/wallpaper`
2. In Vim, press `<leader>tp` or run `:PywalTheme` to apply the pywal colors
3. The pywal theme will be applied while maintaining Vim's syntax highlighting structure
4. If the themer mode is set to 'pywal', Vim loads the current pywal generated theme and ignores the manually saved theme 

### Theme Persistence

- After selecting a theme you like, save it as default with `<leader>ts` or `:SaveTheme`
- The saved theme will be automatically applied in future Vim sessions
- Works with both traditional colorschemes and pywal-generated themes

## Advanced Configuration

### Multiple Colorscheme Directories

themer.vim can search for colorschemes in multiple directories:

```vim
let g:vim_themer_dirs = [
    \ '~/.vim/pack/colors/start',
    \ '~/.vim/colors',
    \ '/usr/share/vim/vimfiles/colors'
\]
```

### Background Mode Control

Control how themer.vim handles light/dark background settings:

```vim
" Automatic detection based on colorscheme brightness
let g:vim_themer_background = "auto"

" Force light mode
let g:vim_themer_background = "light"

" Force dark mode
let g:vim_themer_background = "dark"
```

### Silent Mode

Enable silent mode to suppress informational messages:

```vim
let g:vim_themer_silent = 1
```

## Troubleshooting

### Common Issues

1. **Theme Not Found**
   - Ensure the theme is in one of the directories specified in `g:vim_themer_dirs`
   - Check that the theme file has a `.vim` extension

2. **Pywal Integration Not Working**
   - Verify pywal is installed and has generated colors (`~/.cache/wal/colors.json` should exist)
   - Make sure you've run pywal at least once to generate the initial color scheme

3. **FZF Not Opening**
   - Confirm FZF is properly installed and updated
   - Check that the FZF Vim plugin is loaded before themer.vim

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

themer.vim is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

# themer.vim

A Vim plugin for seamless colorscheme management with FZF integration and pywal support. themer.vim provides an intuitive interface for selecting, applying, and managing colorschemes, including support for pywal-generated themes.

## Features

- 🎨 FZF-powered colorscheme selector with real-time preview
- 🔍 Split-window preview mode for visual theme browsing
- 🔄 Pywal integration for system-wide color consistency
- 💾 Theme persistence across sessions
- ⚡ Quick theme switching with customizable keybindings
- 🌓 Background toggle for light/dark modes with traditional themes
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
let g:vim_themer_preview = 0                          " Options: 0 (centered), 1 (preview)

" Optional: Disable default keybindings
let g:vim_themer_disable_keybindings = 0

" Optional: Customize keybindings
let g:vim_themer_keymap_theme_select = '<leader>tt'   " Fuzzy find themes
let g:vim_themer_keymap_pywal = '<leader>tp'         " Load pywal theme
let g:vim_themer_keymap_save_theme = '<leader>ts'    " Save current theme
let g:vim_themer_keymap_toggle_background = '<leader>tb' " Toggle light/dark background
```

## Commands

themer.vim provides the following commands:

| Command | Description | Default Keybinding |
|---------|-------------|-------------------|
| `:ThemeSelect` | Open FZF theme selector | `<leader>tt` |
| `:PywalTheme` | Apply pywal colorscheme | `<leader>tp` |
| `:SaveTheme` | Save current theme as default | `<leader>ts` |
| `:ToggleBackground` | Toggle light/dark background modes | `<leader>tb` |

## Usage

### Theme Selection and Preview

themer.vim offers two modes for theme selection:

#### Preview Mode (Split Window)
1. Enable preview mode in your configuration: `let g:vim_themer_preview = 1`
2. Press `<leader>tt` or run `:ThemeSelect` to open the split-window selector
3. Navigate through themes to see real-time previews in your actual buffer
4. Select a theme to apply it permanently, or exit to restore the original theme

#### Standard Mode (Centered Window)
1. Keep preview mode disabled: `let g:vim_themer_preview = 0`
2. Press `<leader>tt` or run `:ThemeSelect` to open the centered selector
3. Use FZF's fuzzy finding to search and select themes
4. The selected theme will be applied upon confirmation

### Pywal Integration

1. First, generate a color scheme using pywal: `wal -i /path/to/wallpaper`
2. In Vim, press `<leader>tp` or run `:PywalTheme` to apply the pywal colors
3. If the mode is set to 'pywal', themer.vim will always load the current pywal theme

### Background Toggle

1. Toggle between light and dark background modes for traditional themes using `<leader>tb` or `:ToggleBackground`
2. For pywal themes, the toggle function preserves the current pywal-applied theme

### Theme Persistence
- Save a theme as default with `<leader>ts` or `:SaveTheme`
- For traditional themes, the saved theme will automatically load in future sessions
- For pywal themes, a saved pywal configuration will load the saved colors, but live updates always use the current pywal state

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

### Preview Mode Configuration

Control how themer.vim displays the theme selector:

```vim
" Enable split-window preview mode with real-time theme preview
let g:vim_themer_preview = 1

" Use centered window without preview
let g:vim_themer_preview = 0
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

4. **Preview Mode Issues**
   - Ensure your Vim version is recent enough to support timer functionality
   - Check that your terminal supports the required features for split windows

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

themer.vim is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

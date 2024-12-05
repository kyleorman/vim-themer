# themer.vim

A Vim plugin for seamless colorscheme management with FZF integration and Pywal support. `themer.vim` provides an intuitive interface for selecting, applying, and managing colorschemes, including support for Pywal-generated themes with automatic updates.

## Features

- 🎨 FZF-powered colorscheme selector with real-time preview
- 🔄 **Automatic Pywal theme updates** with periodic checking (Pywal mode)
- 📜 **Mode persistence** across sessions (Pywal or manual mode)
- 💾 Theme persistence and saving across sessions
- ⚡ Quick theme switching with customizable keybindings
- 🌍 Background toggle for light/dark modes with traditional themes
- 🌀 Support for multiple colorscheme directories

## Installation

### Requirements

- Vim 8.0+ with Python support and `+timer` feature
- [FZF](https://github.com/junegunn/fzf) (for colorscheme selection)
- [Pywal](https://github.com/dylanaraps/pywal) (optional, for Pywal integration)

### Using a Plugin Manager

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'junegunn/fzf'  " Required dependency
Plug 'kyleorman/vim-themer'
```

## Configuration

Add these settings to your `vimrc` to customize `themer.vim`'s behavior:

```vim
" Default settings shown below
let g:vim_themer_dirs = ['~/.vim/pack/colors/start']  " Colorscheme directories
let g:vim_themer_mode = "manual"                      " Options: 'manual', 'pywal'
let g:vim_themer_background = "auto"                  " Options: 'light', 'dark', 'auto'
let g:vim_themer_silent = 0                           " Options: 0 (verbose), 1 (silent)
let g:vim_themer_preview = 1                          " Options: 0 (centered), 1 (preview)
let g:vim_themer_disable_keybindings = 0              " Options: 0 (enable), 1 (disable)

" Optional: Customize keybindings
let g:vim_themer_keymap_theme_select = '<leader>tt'        " Fuzzy find themes
let g:vim_themer_keymap_pywal = '<leader>tp'               " Toggle Pywal mode
let g:vim_themer_keymap_save_theme = '<leader>ts'          " Save current theme
let g:vim_themer_keymap_toggle_background = '<leader>tb'   " Toggle light/dark background
let g:vim_themer_keymap_toggle_mode = '<leader>tm'         " Toggle between Pywal and manual modes
let g:vim_themer_keymap_toggle_preview = '<leader>tv'      " Toggle preview mode in theme selector
```

## Commands

`themer.vim` provides the following commands:

| Command                | Description                                      | Default Keybinding  |
|------------------------|--------------------------------------------------|---------------------|
| `:ThemeSelect`         | Open FZF theme selector                          | `<leader>tt`        |
| `:PywalTheme`          | Apply Pywal colorscheme manually                 | `<leader>tp`        |
| `:SaveTheme`           | Save current theme as default                    | `<leader>ts`        |
| `:ToggleBackground`    | Toggle light/dark background modes               | `<leader>tb`        |
| `:ThemeToggleMode`     | Toggle between Pywal and manual modes            | `<leader>tm`        |
| `:ThemeTogglePreview`  | Toggle preview mode in theme selector            | `<leader>tv`        |

## Usage

### Mode Selection and Persistence

`themer.vim` supports two modes of operation:

- **Manual Mode**: Allows you to select and save themes manually.
- **Pywal Mode**: Automatically applies the current Pywal theme, updating whenever Pywal's `colors.json` changes.

The plugin remembers your last selected mode across Vim sessions.

#### Switching Modes

- Use `<leader>tm` or `:ThemeToggleMode` to toggle between Pywal and manual modes.
- The current mode is saved and will be restored on the next Vim startup.

### Theme Selection and Preview

`themer.vim` offers two modes for theme selection:

#### Preview Mode (Split Window)

1. Ensure preview mode is enabled: `let g:vim_themer_preview = 1`
2. Press `<leader>tt` or run `:ThemeSelect` to open the split-window selector.
3. Navigate through themes to see real-time previews in your actual buffer.
4. Select a theme to apply it permanently, or exit to restore the original theme.

#### Standard Mode (Centered Window)

1. Disable preview mode: `let g:vim_themer_preview = 0`
2. Press `<leader>tt` or run `:ThemeSelect` to open the centered selector.
3. Use FZF's fuzzy finding to search and select themes.
4. The selected theme will be applied upon confirmation.

### Pywal Integration and Automatic Updates

When in Pywal mode, `themer.vim` automatically applies the current Pywal theme and updates it whenever `colors.json` changes.

#### Enabling Pywal Mode

- Toggle to Pywal mode using `<leader>tm` or `:ThemeToggleMode`.
- The plugin will apply the current Pywal theme and start monitoring for changes.

#### Automatic Theme Updates

- `themer.vim` checks for updates to Pywal's `colors.json` every 5 seconds.
- When `colors.json` is updated (e.g., after running `wal` with a new image), the Vim theme updates automatically.

#### Disabling Automatic Updates

- Switch back to manual mode using `<leader>tm` or `:ThemeToggleMode`.
- Automatic updates will stop, and you can select themes manually.

### Background Toggle

- Toggle between light and dark background modes for traditional themes using `<leader>tb` or `:ToggleBackground`.
- For Pywal themes, the background toggle is not available, as the theme is determined by Pywal.

### Theme Persistence

- Save a theme as default with `<leader>ts` or `:SaveTheme`.
- The saved theme will automatically load in future sessions.
- The plugin uses the XDG Base Directory specification for storing configuration and cache files, ensuring compatibility across different systems.

## Advanced Configuration

### Multiple Colorscheme Directories

`themer.vim` can search for colorschemes in multiple directories:

```vim
let g:vim_themer_dirs = [
    \ '~/.vim/pack/colors/start',
    \ '~/.vim/colors',
    \ '/usr/share/vim/vimfiles/colors'
\]
```

### Preview Mode Configuration

Control how `themer.vim` displays the theme selector:

```vim
" Enable split-window preview mode with real-time theme preview
let g:vim_themer_preview = 1

" Use centered window without preview
let g:vim_themer_preview = 0
```

Toggle preview mode dynamically using `<leader>tv` or `:ThemeTogglePreview`.

### Background Mode Control

Control how `themer.vim` handles light/dark background settings:

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

### Keybinding Customization

Disable default keybindings and set your own:

```vim
" Disable default keybindings
let g:vim_themer_disable_keybindings = 1

" Set custom keybindings
nnoremap <silent> <leader>th :ThemeSelect<CR>
nnoremap <silent> <leader>pm :PywalTheme<CR>
```

### Pywal Update Interval

Adjust the interval for checking Pywal updates (in milliseconds):

```vim
" In your vimrc, before the plugin is loaded
let g:vim_themer_pywal_update_interval = 5000  " Check every 5 seconds (default)
```

*Note: This variable should be set before the plugin is loaded.*

## Troubleshooting

### Common Issues

1. **Theme Not Found**
   - Ensure the theme is in one of the directories specified in `g:vim_themer_dirs`.
   - Check that the theme file has a `.vim` extension.

2. **Pywal Integration Not Working**
   - Verify Pywal is installed and has generated colors (`~/.cache/wal/colors.json` should exist).
   - Make sure you've run Pywal at least once to generate the initial color scheme.
   - Ensure you are in Pywal mode (`g:vim_themer_mode` is set to `'pywal'`).

3. **Automatic Pywal Updates Not Working**
   - Confirm that Vim supports timers (`+timer` feature).
   - Check that the plugin is in Pywal mode.
   - Ensure `colors.json` is being updated by Pywal.

4. **FZF Not Opening**
   - Confirm FZF is properly installed and updated.
   - Check that the FZF Vim plugin is loaded before `themer.vim`.

5. **Preview Mode Issues**
   - Ensure your Vim version supports the required features for split windows.
   - Verify that `g:vim_themer_preview` is set correctly.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue for bug reports and feature requests.

## License

`themer.vim` is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.


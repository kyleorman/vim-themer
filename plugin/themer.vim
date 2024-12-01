" themer: Plugin initialization and commands

" Default directories for colorschemes (existing code)
if !exists('g:vim_themer_dirs')
    let g:vim_themer_dirs = ['~/.vim/pack/colors/start']
endif

" Set the default mode if not defined by the user (existing code)
if !exists('g:vim_themer_mode')
    let g:vim_themer_mode = "manual"  " Options: 'pywal', 'manual'
endif

" Set the default background behavior if not defined by the user (existing code)
if !exists('g:vim_themer_background')
    let g:vim_themer_background = "auto"  " Options: 'light', 'dark', 'auto'
endif

" Set the default silent mode behavior if not defined by the user (existing code)
if !exists('g:vim_themer_silent')
    let g:vim_themer_silent = 0  " Options: 0 (false), 1 (true)
endif

" Load saved default theme based on mode (existing code)
if filereadable(expand('~/.vim_themer_default'))
    call themer#apply_saved_theme()
endif

" Command: ThemeSelect - Open the FZF selector (existing code)
command! ThemeSelect call themer#show_selector()

" Command: PywalTheme - Apply pywal-generated colorscheme (existing code)
command! PywalTheme call themer#apply_pywal()

" Command: SaveTheme - Save the current colorscheme as default (existing code)
command! SaveTheme call themer#save_theme()

" Command: ToggleBackground - Toggle between light and dark background
command! ToggleBackground call themer#toggle_background()

" Keybinding configuration
if !exists('g:vim_themer_disable_keybindings') || g:vim_themer_disable_keybindings == 0

    " Set default keymaps for themer commands if user has not defined their own
    if !exists('g:vim_themer_keymap_theme_select')
        let g:vim_themer_keymap_theme_select = '<leader>tt'
    endif
    if !exists('g:vim_themer_keymap_pywal')
        let g:vim_themer_keymap_pywal = '<leader>tp'
    endif
    if !exists('g:vim_themer_keymap_save_theme')
        let g:vim_themer_keymap_save_theme = '<leader>ts'
    endif
    if !exists('g:vim_themer_keymap_toggle_background')
        let g:vim_themer_keymap_toggle_background = '<leader>tb'
    endif

    " Apply keybindings only if no pre-existing user keybinding
    if !hasmapto(':ThemeSelect') && g:vim_themer_keymap_theme_select != ''
        execute 'nnoremap <silent> ' . g:vim_themer_keymap_theme_select . ' :ThemeSelect<CR>'
    endif

    if !hasmapto(':PywalTheme') && g:vim_themer_keymap_pywal != ''
        execute 'nnoremap <silent> ' . g:vim_themer_keymap_pywal . ' :PywalTheme<CR>'
    endif

    if !hasmapto(':SaveTheme') && g:vim_themer_keymap_save_theme != ''
        execute 'nnoremap <silent> ' . g:vim_themer_keymap_save_theme . ' :SaveTheme<CR>'
    endif

    if !hasmapto(':ToggleBackground') && g:vim_themer_keymap_toggle_background != ''
        execute 'nnoremap <silent> ' . g:vim_themer_keymap_toggle_background . ' :ToggleBackground<CR>'
    endif

endif

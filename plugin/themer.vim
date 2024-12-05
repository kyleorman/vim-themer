" plugin/themer.vim

" Default directories for colorschemes
if !exists('g:vim_themer_dirs')
    let g:vim_themer_dirs = ['~/.vim/pack/colors/start']
endif

" Set default settings if not defined by user
if !exists('g:vim_themer_mode')
    let g:vim_themer_mode = "manual"  " Options: 'pywal', 'manual'
endif

if !exists('g:vim_themer_background')
    let g:vim_themer_background = "auto"  " Options: 'light', 'dark', 'auto'
endif

if !exists('g:vim_themer_silent')
    let g:vim_themer_silent = 0  " Options: 0 (false), 1 (true)
endif

if !exists('g:vim_themer_preview')
    let g:vim_themer_preview = 1  " Enable preview by default
endif

" Define core commands
command! ThemeSelect call themer#show_selector()
command! PywalTheme call themer#apply_pywal()
command! SaveTheme call themer#save_theme()
command! ToggleBackground call themer#toggle_background()

" Define mode and preview commands
command! ThemeToggleMode call themer#toggle_mode()
command! ThemeTogglePreview call themer#toggle_preview()

" Keybinding configuration
if !exists('g:vim_themer_disable_keybindings') || g:vim_themer_disable_keybindings == 0
    " Set default keymaps for core functionality
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

    " Set default keymaps for mode and preview toggling
    if !exists('g:vim_themer_keymap_toggle_mode')
        let g:vim_themer_keymap_toggle_mode = '<leader>tm'
    endif

    if !exists('g:vim_themer_keymap_toggle_preview')
        let g:vim_themer_keymap_toggle_preview = '<leader>tv'
    endif

    " Apply keybindings only if no pre-existing mappings exist
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

    if !hasmapto(':ThemeToggleMode') && g:vim_themer_keymap_toggle_mode != ''
        execute 'nnoremap <silent> ' . g:vim_themer_keymap_toggle_mode . ' :ThemeToggleMode<CR>'
    endif

    if !hasmapto(':ThemeTogglePreview') && g:vim_themer_keymap_toggle_preview != ''
        execute 'nnoremap <silent> ' . g:vim_themer_keymap_toggle_preview . ' :ThemeTogglePreview<CR>'
    endif
endif

" Initialize theme settings and load saved theme
call themer#load_theme_settings()

" Handle initial theme loading based on mode
if g:vim_themer_mode ==# "pywal"
    call themer#apply_pywal()
else
    " Stop the Pywal timer in case it was running
    call themer#stop_pywal_timer()
    call themer#apply_saved_theme()
endif

" Clean up on Vim exit
autocmd VimLeavePre * call themer#stop_pywal_timer()

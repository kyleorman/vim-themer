" autoload/themer.vim

" Storage for theme-specific settings
let s:theme_settings = {}

" XDG directory management functions
function! themer#get_config_dir() abort
    let l:xdg_config = exists('$XDG_CONFIG_HOME') ? $XDG_CONFIG_HOME : expand('~/.config')
    let l:config_dir = l:xdg_config . '/vim-themer'

    if !isdirectory(l:config_dir)
        call mkdir(l:config_dir, 'p')
    endif

    return l:config_dir
endfunction

function! themer#get_data_dir() abort
    let l:xdg_data = exists('$XDG_DATA_HOME') ? $XDG_DATA_HOME : expand('~/.local/share')
    let l:data_dir = l:xdg_data . '/vim-themer'

    if !isdirectory(l:data_dir)
        call mkdir(l:data_dir, 'p')
    endif

    return l:data_dir
endfunction

function! themer#get_cache_dir() abort
    let l:xdg_cache = exists('$XDG_CACHE_HOME') ? $XDG_CACHE_HOME : expand('~/.cache')
    let l:cache_dir = l:xdg_cache . '/vim-themer'

    if !isdirectory(l:cache_dir)
        call mkdir(l:cache_dir, 'p')
    endif

    return l:cache_dir
endfunction

" Function to locate Pywal's colors.json
function! themer#get_pywal_colors_path() abort
    let l:paths = []
    let l:xdg_cache_home = exists('$XDG_CACHE_HOME') ? $XDG_CACHE_HOME : ''
    if !empty(l:xdg_cache_home)
        call add(l:paths, l:xdg_cache_home . '/wal/colors.json')
    endif
    call add(l:paths, expand('~/.cache/wal/colors.json'))

    for l:path in l:paths
        if filereadable(l:path)
            return l:path
        endif
    endfor
    return ''
endfunction

function! themer#get_pywal_cache_path() abort
    return themer#get_data_dir() . '/pywal-cache.json'
endfunction

function! themer#get_default_theme_path() abort
    return themer#get_config_dir() . '/default-theme'
endfunction

function! themer#store_original_theme() abort
    let t:themer_original_theme = get(g:, 'colors_name', '')
    let t:themer_was_pywal = exists('g:current_color_scheme') && g:current_color_scheme ==# 'pywal'
    let t:themer_original_background = &background
endfunction

function! themer#restore_original_theme() abort
    if exists('t:themer_was_pywal') && t:themer_was_pywal
        let l:colors_path = themer#get_pywal_colors_path()
        if !empty(l:colors_path)
            call themer#apply_pywal()
        elseif filereadable(themer#get_pywal_cache_path())
            let l:colors_dict = json_decode(join(readfile(themer#get_pywal_cache_path()), "\n"))
            call themer#apply_pywal_from_dict(l:colors_dict)
        endif
    elseif exists('t:themer_original_theme') && !empty(t:themer_original_theme)
        call themer#set_theme(t:themer_original_theme)
        if exists('t:themer_original_background')
            execute 'set background=' . t:themer_original_background
        endif
    endif

    unlet! t:themer_original_theme
    unlet! t:themer_was_pywal
    unlet! t:themer_original_background
endfunction

function! themer#load_theme_settings() abort
    let l:settings_file = themer#get_config_dir() . '/settings.json'
    if filereadable(l:settings_file)
        try
            let s:settings_data = json_decode(join(readfile(l:settings_file), "\n"))
            if has_key(s:settings_data, 'themes')
                let s:theme_settings = s:settings_data['themes']
            else
                let s:theme_settings = {}
            endif
            if has_key(s:settings_data, 'mode')
                let g:vim_themer_mode = s:settings_data['mode']
            endif
        catch
            let s:theme_settings = {}
        endtry
    endif
endfunction

function! themer#save_theme_settings() abort
    let l:settings_file = themer#get_config_dir() . '/settings.json'

    let s:settings_data = {
            \ 'themes': s:theme_settings,
            \ 'mode': g:vim_themer_mode
            \ }

    try
        call writefile([json_encode(s:settings_data)], l:settings_file)
    catch
        echohl ErrorMsg | echom "Theme error: Could not save theme settings" | echohl None
    endtry
endfunction

function! themer#toggle_mode() abort
    let g:vim_themer_mode = g:vim_themer_mode ==# "manual" ? "pywal" : "manual"

    " Save the mode setting
    call themer#save_theme_settings()

    if g:vim_themer_mode ==# "pywal"
        call themer#apply_pywal()
    else
        " Stop the Pywal timer
        call themer#stop_pywal_timer()
        call themer#apply_saved_theme()
    endif
endfunction

function! themer#toggle_preview() abort
    let g:vim_themer_preview = !get(g:, 'vim_themer_preview', 1)
    if !get(g:, 'vim_themer_silent', 0)
        echom "Preview mode: " . (g:vim_themer_preview ? "enabled" : "disabled")
    endif
endfunction

function! themer#create_preview_window()
    let l:orig_win = win_getid()

    botright vnew
    let t:themer_preview_win = winnr()
    let t:themer_preview_buf = bufnr('%')

    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal nonumber
    setlocal norelativenumber
    setlocal nocursorline
    setlocal nocursorcolumn

    " Sample code for preview
    call setline(1, [
        \ '#!/usr/bin/env python',
        \ '"""Themer Color Preview."""',
        \ '',
        \ 'from typing import Dict, List, Optional, Union',
        \ 'from dataclasses import dataclass',
        \ 'from abc import ABC, abstractmethod',
        \ '',
        \ '@dataclass',
        \ 'class ColorValue:',
        \ '    """Represents a color value with validation."""',
        \ '    hex_value: str',
        \ '',
        \ '    def __post_init__(self):',
        \ '        if not self.hex_value.startswith("#"):',
        \ '            raise ValueError("Color must start with #")',
        \ '        if len(self.hex_value) != 7:',
        \ '            raise ValueError("Invalid color length")',
        \ '',
        \ 'class ThemeComponent(ABC):',
        \ '    """Base class for theme components."""',
        \ '',
        \ '    @abstractmethod',
        \ '    def apply(self) -> bool:',
        \ '        """Apply the theme component."""',
        \ '        pass',
        \ '',
        \ 'class ColorScheme(ThemeComponent):',
        \ '    """Manages a color scheme with primary and accent colors."""',
        \ '',
        \ '    def __init__(self, name: str):',
        \ '        self.name = name',
        \ '        self.colors: Dict[str, ColorValue] = {',
        \ '            "primary": ColorValue("#FF0000"),',
        \ '            "secondary": ColorValue("#00FF00"),',
        \ '            "accent": ColorValue("#0000FF")',
        \ '        }',
        \ '        self._active = False',
        \ '',
        \ '    @property',
        \ '    def is_active(self) -> bool:',
        \ '        """Check if the color scheme is currently active."""',
        \ '        return self._active',
        \ '',
        \ '    def add_color(self, name: str, value: str) -> None:',
        \ '        """Add a new color to the scheme."""',
        \ '        self.colors[name] = ColorValue(value)',
        \ '',
        \ '    def apply(self) -> bool:',
        \ '        """Apply the color scheme."""',
        \ '        try:',
        \ '            for name, color in self.colors.items():',
        \ '                print(f"Applying {name}: {color.hex_value}")',
        \ '            self._active = True',
        \ '            return True',
        \ '        except Exception as e:',
        \ '            print(f"Failed to apply theme: {e}")',
        \ '            return False',
        \ ])

    setlocal filetype=python
    setlocal nomodifiable

    call win_gotoid(l:orig_win)
endfunction

function! themer#show_selector()
    call themer#store_original_theme()

    let l:colorschemes = []
    for l:dir in g:vim_themer_dirs
        let l:expanded_dir = expand(l:dir)
        if isdirectory(l:expanded_dir)
            let l:files = globpath(l:expanded_dir, '**/*.vim', 0, 1)
            for l:file in l:files
                if l:file =~ '/colors/[^/]\+\.vim$' && join(readfile(l:file), "\n") =~ '\vhighlight|hi\s|link\s|set\s+background='
                    call add(l:colorschemes, fnamemodify(l:file, ":t:r"))
                endif
            endfor
        endif
    endfor

    if empty(l:colorschemes)
        echohl ErrorMsg | echo "No colorschemes found" | echohl None
        return
    endif

    let l:preview_enabled = get(g:, 'vim_themer_preview', 1)
    let l:tmp = ''
    let l:current_scheme = exists('g:current_color_scheme') ? g:current_color_scheme : ''
    let s:preview_background = !empty(l:current_scheme) && has_key(s:theme_settings, l:current_scheme) ?
        \ s:theme_settings[l:current_scheme].background : 'dark'

    if l:preview_enabled
        call themer#create_preview_window()
        let l:tmp = tempname()

        function! s:apply_theme_realtime(timer) abort
            if filereadable(g:themer_tmp_file)
                let l:theme = readfile(g:themer_tmp_file)[0]
                try
                    execute 'set background=' . s:preview_background
                    execute 'colorscheme ' . l:theme
                catch
                endtry
                call delete(g:themer_tmp_file)
            endif
        endfunction

        let g:themer_tmp_file = l:tmp
        let g:themer_timer = timer_start(50, function('s:apply_theme_realtime'), {'repeat': -1})
    endif

    let l:opts = {
        \ 'source': uniq(sort(l:colorschemes)),
        \ 'sink*': function('s:handle_fzf_exit'),
        \ 'options': [
        \   '--preview-window', l:preview_enabled ? 'right:50%' : 'hidden',
        \   '--expect', 'ctrl-c,esc',
        \   '--bind', 'alt-b:execute-silent:let s:preview_background = s:preview_background ==# "dark" ? "light" : "dark"'
        \ ],
        \ 'window': {
        \   'width': l:preview_enabled ? 0.5 : 0.4,
        \   'height': l:preview_enabled ? 1.0 : 0.6,
        \   'yoffset': l:preview_enabled ? 0 : 0.2,
        \   'xoffset': l:preview_enabled ? 0 : 0.5,
        \   'border': l:preview_enabled ? 'none' : 'rounded'
        \ }
    \ }

    if l:preview_enabled
        call extend(l:opts.options, ['--bind', printf('focus:execute-silent(echo {} > %s)', l:tmp)])
    endif

    call fzf#run(fzf#wrap(l:opts))

    augroup ThemerPreview
        autocmd!
        autocmd User FzfStatusChange call s:handle_fzf_exit([])
        autocmd VimLeavePre * call s:handle_fzf_exit([])
    augroup END
endfunction

function! s:handle_fzf_exit(lines) abort
    if exists('g:themer_timer')
        call timer_stop(g:themer_timer)
        unlet g:themer_timer
    endif
    if exists('g:themer_tmp_file')
        call delete(g:themer_tmp_file)
        unlet g:themer_tmp_file
    endif

    call themer#cleanup_preview()

    if len(a:lines) > 1 && empty(a:lines[0]) && !empty(a:lines[1])
        let s:theme_settings[a:lines[1]] = {'background': s:preview_background}
        call themer#set_theme(a:lines[1])
    else
        call themer#restore_original_theme()
    endif
endfunction

function! themer#cleanup_preview() abort
    if exists('t:themer_preview_win')
        if win_id2win(win_getid(t:themer_preview_win))
            execute 'bwipeout ' . t:themer_preview_buf
        endif
        unlet! t:themer_preview_win
        unlet! t:themer_preview_buf
    endif
endfunction

function! themer#set_theme(name) abort
    try
        if !has_key(s:theme_settings, a:name)
            let s:theme_settings[a:name] = {'background': 'dark'}
        endif

        execute 'set background=' . s:theme_settings[a:name].background
        execute 'colorscheme ' . a:name
        let g:current_color_scheme = a:name

        call themer#save_theme_settings()

        if !get(g:, 'vim_themer_silent', 0)
            echom "Theme: " . a:name . " (" . s:theme_settings[a:name].background . ")"
        endif
    catch /^Vim\%((\a\+)\)\=:E185/
        echohl ErrorMsg | echom "Theme not found: " . a:name | echohl None
    catch
        echohl ErrorMsg | echom "Error setting theme: " . a:name | echohl None
    endtry
endfunction

function! themer#apply_pywal()
    let l:colors_path = themer#get_pywal_colors_path()
    if !empty(l:colors_path)
        try
            let l:colors_dict = json_decode(join(readfile(l:colors_path), "\n"))
        catch
            echohl ErrorMsg | echom "Theme error: Invalid pywal colors.json" | echohl None
            return
        endtry

        call themer#apply_pywal_from_dict(l:colors_dict)
        let g:current_color_scheme = "pywal"

        " Save the initial modification time
        let s:pywal_colors_mtime = getftime(l:colors_path)
        " Start the timer to check for updates
        call themer#start_pywal_timer()

        call themer#save_theme_settings()

        if !get(g:, 'vim_themer_silent', 0)
            echom "Theme: pywal"
        endif
    else
        echohl ErrorMsg | echom "Theme error: pywal colors.json not found" | echohl None
    endif
endfunction

" Start the timer to check for changes in colors.json
function! themer#start_pywal_timer() abort
    " Stop any existing timer
    if exists('s:pywal_timer')
        call timer_stop(s:pywal_timer)
        unlet s:pywal_timer
    endif
    " Start a new timer that checks every 5 seconds (5000 milliseconds)
    let s:pywal_timer = timer_start(5000, 'themer#check_pywal_update', {'repeat': -1})
endfunction

" Stop the timer when Pywal mode is exited
function! themer#stop_pywal_timer() abort
    if exists('s:pywal_timer')
        call timer_stop(s:pywal_timer)
        unlet s:pywal_timer
    endif
endfunction

" Callback function to check for updates
function! themer#check_pywal_update(timer_id) abort
    let l:colors_path = themer#get_pywal_colors_path()
    if empty(l:colors_path)
        return
    endif
    let l:mtime = getftime(l:colors_path)
    if l:mtime !=# s:pywal_colors_mtime
        " Update the stored modification time
        let s:pywal_colors_mtime = l:mtime
        " Re-apply the Pywal theme
        call themer#apply_pywal()
        if !get(g:, 'vim_themer_silent', 0)
            echom "Pywal theme updated."
        endif
    endif
endfunction

function! themer#apply_pywal_from_dict(colors_dict)
    execute 'highlight clear'

    let l:bg = a:colors_dict['special']['background']
    let l:fg = a:colors_dict['special']['foreground']
    let l:cursor = a:colors_dict['special']['cursor']

    if g:vim_themer_background ==# "auto"
        let l:brightness = str2nr(matchstr(l:bg, '^#\(\x\{2\}\)'), 16)
        let l:background_setting = (l:brightness < 128 ? "dark" : "light")
    else
        let l:background_setting = g:vim_themer_background
    endif

    try
        execute 'highlight Normal guibg=' . l:bg . ' guifg=' . l:fg
        execute 'highlight Cursor guifg=' . l:bg . ' guibg=' . l:cursor
        execute 'set background=' . l:background_setting
    catch
        echohl ErrorMsg | echom "Theme error: Failed to set colors" | echohl None
    endtry

    let l:colors = a:colors_dict['colors']

    try
        execute 'highlight Comment guifg=' . l:colors['color8'] . ' gui=italic'
        execute 'highlight Constant guifg=' . l:colors['color3']
        execute 'highlight Identifier guifg=' . l:colors['color4']
        execute 'highlight Statement guifg=' . l:colors['color1']
        execute 'highlight PreProc guifg=' . l:colors['color5']
        execute 'highlight Type guifg=' . l:colors['color6']
        execute 'highlight Special guifg=' . l:colors['color2']
        execute 'highlight Underlined guifg=' . l:colors['color12'] . ' gui=underline'
        execute 'highlight Todo guifg=' . l:colors['color1'] . ' guibg=' . l:colors['color7'] . ' gui=bold'
        execute 'highlight Error guifg=' . l:colors['color0'] . ' guibg=' . l:colors['color9'] . ' gui=bold'
        execute 'highlight LineNr guifg=' . l:colors['color8']
        execute 'highlight CursorLineNr guifg=' . l:colors['color12']
        execute 'highlight Visual guibg=' . l:colors['color10']
        execute 'highlight StatusLine guibg=' . l:colors['color0'] . ' guifg=' . l:colors['color7']
        execute 'highlight StatusLineNC guibg=' . l:colors['color0'] . ' guifg=' . l:colors['color8']
        execute 'highlight VertSplit guifg=' . l:colors['color8']
    catch
        echohl ErrorMsg | echom "Theme error: Failed to apply highlights" | echohl None
    endtry
endfunction

function! themer#save_theme()
    if !exists('g:current_color_scheme')
        echohl ErrorMsg | echom "Theme error: No active theme to save" | echohl None
        return
    endif

    if g:current_color_scheme ==# "pywal"
        let l:colors_path = themer#get_pywal_colors_path()
        if !empty(l:colors_path)
            try
                call writefile([g:current_color_scheme], themer#get_default_theme_path())
                call writefile(readfile(l:colors_path), themer#get_pywal_cache_path())
                if !get(g:, 'vim_themer_silent', 0)
                    echom "Theme: pywal (saved)"
                endif
            catch
                echohl ErrorMsg | echom "Theme error: Failed to save pywal colors" | echohl None
            endtry
        else
            echohl ErrorMsg | echom "Theme error: pywal colors.json not found" | echohl None
        endif
    else
        call writefile([g:current_color_scheme], themer#get_default_theme_path())
        if !get(g:, 'vim_themer_silent', 0)
            echom "Theme: " . g:current_color_scheme . " (saved)"
        endif
    endif
endfunction

function! themer#apply_saved_theme()
    if g:vim_themer_mode ==# "pywal"
        call themer#apply_pywal()
        return
    endif

    if filereadable(themer#get_default_theme_path())
        let l:saved_theme = trim(readfile(themer#get_default_theme_path())[0])
        if l:saved_theme ==# "pywal"
            let l:colors_path = themer#get_pywal_cache_path()
            if filereadable(l:colors_path)
                try
                    let l:colors_dict = json_decode(join(readfile(l:colors_path), "\n"))
                    call themer#apply_pywal_from_dict(l:colors_dict)
                catch
                    echohl ErrorMsg | echom "Theme error: Failed to apply saved pywal theme" | echohl None
                endtry
            else
                echohl ErrorMsg | echom "Theme error: Saved pywal theme not found" | echohl None
            endif
        else
            call themer#set_theme(l:saved_theme)
        endif
    endif
endfunction

function! themer#toggle_background()
    if exists('g:current_color_scheme') && g:current_color_scheme ==# 'pywal'
        if !get(g:, 'vim_themer_silent', 0)
            echom "Theme: pywal (background toggle unavailable)"
        endif
        return
    endif

    let l:current_theme = get(g:, 'colors_name', '')
    if empty(l:current_theme)
        return
    endif

    if !has_key(s:theme_settings, l:current_theme)
        let s:theme_settings[l:current_theme] = {'background': 'dark'}
    endif

    let l:new_background = s:theme_settings[l:current_theme].background == 'dark' ? 'light' : 'dark'
    let s:theme_settings[l:current_theme].background = l:new_background

    execute 'set background=' . l:new_background
    call themer#save_theme_settings()

    if !get(g:, 'vim_themer_silent', 0)
        echom "Theme: " . l:current_theme . " (" . l:new_background . ")"
    endif
endfunction

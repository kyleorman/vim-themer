" autoload/themer.vim

function! themer#store_original_theme() abort
    let t:themer_original_theme = get(g:, 'colors_name', '')
    let t:themer_was_pywal = exists('g:current_color_scheme') && g:current_color_scheme ==# 'pywal'
endfunction

function! themer#restore_original_theme() abort
    if exists('t:themer_was_pywal') && t:themer_was_pywal
        " Restore pywal theme
        if filereadable(expand('~/.cache/wal/colors.json'))
            call themer#apply_pywal()
        elseif filereadable(expand('~/.vim_themer_saved_pywal.json'))
            let l:colors_dict = json_decode(join(readfile(expand('~/.vim_themer_saved_pywal.json')), "\n"))
            call themer#apply_pywal_from_dict(l:colors_dict)
        endif
    elseif exists('t:themer_original_theme') && !empty(t:themer_original_theme)
        " Restore traditional theme
        execute 'colorscheme ' . t:themer_original_theme
    endif

    " Clean up temporary variables
    unlet! t:themer_original_theme
    unlet! t:themer_was_pywal
endfunction

function! themer#update_preview(theme_name) abort
    if !exists('t:themer_preview_win') || empty(a:theme_name)
        return
    endif

    " Store current state
    let l:cur_win = winnr()

    " Switch to preview window and apply theme
    noautocmd execute t:themer_preview_win . 'wincmd w'
    try
        execute 'colorscheme ' . a:theme_name
        redraw!
    catch
    finally
        " Return to original window
        noautocmd execute l:cur_win . 'wincmd w'
    endtry
endfunction

function! themer#create_preview_window()
    " Save original window
    let l:orig_win = win_getid()

    " Create right split
    botright vnew
    let t:themer_preview_win = winnr()
    let t:themer_preview_buf = bufnr('%')

    " Set up preview buffer
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal nonumber
    setlocal norelativenumber
    setlocal nocursorline
    setlocal nocursorcolumn

    " Extended sample code
    call setline(1, [
        \ '#!/usr/bin/env python',
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
        \ '',
        \ 'def create_default_scheme() -> ColorScheme:',
        \ '    """Create a default color scheme."""',
        \ '    scheme = ColorScheme("Default")',
        \ '    scheme.add_color("background", "#1A1A1A")',
        \ '    scheme.add_color("foreground", "#FFFFFF")',
        \ '    return scheme',
        \ '',
        \ 'if __name__ == "__main__":',
        \ '    # Create and apply a custom theme',
        \ '    theme = create_default_scheme()',
        \ '    if theme.apply():',
        \ '        print(f"Successfully applied theme: {theme.name}")',
        \ ])

    setlocal filetype=python
    setlocal nomodifiable

    " Return to original window
    call win_gotoid(l:orig_win)
endfunction

function! themer#show_selector()
    " Store original theme
    call themer#store_original_theme()

    " Find colorschemes
    let l:colorschemes = []
    for l:dir in g:vim_themer_dirs
        let l:expanded_dir = expand(l:dir)
        if isdirectory(l:expanded_dir)
            let l:files = globpath(l:expanded_dir, '**/*.vim', 0, 1)
            for l:file in l:files
                if join(readfile(l:file), "\n") =~ '\vhighlight|hi\s|link\s|set\s+background='
                    call add(l:colorschemes, fnamemodify(l:file, ":t:r"))
                endif
            endfor
        endif
    endfor

    if empty(l:colorschemes)
        echohl ErrorMsg | echo "No colorschemes found" | echohl None
        return
    endif

    " Determine if preview is enabled
    let l:preview_enabled = get(g:, 'vim_themer_preview', 0)

    " Only set up real-time preview if preview mode is enabled
    let l:tmp = ''
    if l:preview_enabled
        " Create preview window
        call themer#create_preview_window()

        " Create temporary file for communication
        let l:tmp = tempname()

        " Function to apply theme in real-time
        function! s:apply_theme_realtime(timer) abort
            if filereadable(g:themer_tmp_file)
                let l:theme = readfile(g:themer_tmp_file)[0]
                execute 'colorscheme ' . l:theme
                call delete(g:themer_tmp_file)
            endif
        endfunction

        " Set up global variables
        let g:themer_tmp_file = l:tmp
        let g:themer_timer = timer_start(50, function('s:apply_theme_realtime'), {'repeat': -1})
    endif

    " Set up FZF options
    let l:opts = {
        \ 'source': uniq(sort(l:colorschemes)),
        \ 'sink*': function('s:handle_fzf_exit'),
        \ 'options': [
        \   '--preview-window', l:preview_enabled ? 'right:50%' : 'hidden',
        \   '--expect', 'ctrl-c,esc'
        \ ],
        \ 'window': {
        \   'width': l:preview_enabled ? 0.5 : 0.4,
        \   'height': l:preview_enabled ? 1.0 : 0.6,
        \   'yoffset': l:preview_enabled ? 0 : 0.2,
        \   'xoffset': l:preview_enabled ? 0 : 0.5,
        \   'border': l:preview_enabled ? 'none' : 'rounded'
        \ }
    \ }

    " Add real-time preview binding only in preview mode
    if l:preview_enabled
        call extend(l:opts.options, ['--bind', printf('focus:execute-silent(echo {} > %s)', l:tmp)])
    endif

    " Run FZF
    call fzf#run(fzf#wrap(l:opts))

    " Set up cleanup
    augroup ThemerPreview
        autocmd!
        autocmd User FzfStatusChange call s:cleanup_and_restore()
        autocmd VimLeavePre * call s:cleanup_and_restore()
    augroup END
endfunction

function! s:handle_fzf_exit(lines) abort
    " Clean up timer and temporary file
    if exists('g:themer_timer')
        call timer_stop(g:themer_timer)
        unlet g:themer_timer
    endif
    if exists('g:themer_tmp_file')
        call delete(g:themer_tmp_file)
        unlet g:themer_tmp_file
    endif

    call themer#cleanup_preview()
    
    " Check for a proper theme selection
    " This happens when:
    " 1. We have at least 2 lines in the output
    " 2. The first line is empty (indicating normal selection, not ctrl-c/esc)
    " 3. The second line contains the selected theme
    if len(a:lines) > 1 && empty(a:lines[0]) && !empty(a:lines[1])
        call themer#set_theme(a:lines[1])
    else
        " Restore the original theme for any other exit case
        call themer#restore_original_theme()
    endif
endfunction

function! s:cleanup_and_restore() abort
    " Clean up timer and temporary file
    if exists('g:themer_timer')
        call timer_stop(g:themer_timer)
        unlet g:themer_timer
    endif
    if exists('g:themer_tmp_file')
        call delete(g:themer_tmp_file)
        unlet g:themer_tmp_file
    endif

    call themer#cleanup_preview()
    call themer#restore_original_theme()
endfunction

function! themer#cleanup_preview() abort
    if exists('t:themer_preview_win')
        " Only try to close if the window still exists
        if win_id2win(win_getid(t:themer_preview_win))
            execute 'bwipeout ' . t:themer_preview_buf
        endif
        
        " Clean up variables
        unlet! t:themer_preview_win
        unlet! t:themer_preview_buf
    endif
endfunction

function! themer#set_theme(name)
    try
        execute 'colorscheme ' . a:name
        let g:current_color_scheme = a:name
        if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
            echom "Colorscheme set to: " . a:name
        endif
    catch /^Vim\%((\a\+)\)\=:E185/
        echohl ErrorMsg | echom "Colorscheme not found: " . a:name | echohl None
    catch
        echohl ErrorMsg | echom "Error setting colorscheme: " . a:name | echohl None
    endtry
endfunction

function! themer#apply_pywal()
    let l:colors_json_path = expand('~/.cache/wal/colors.json')
    if !filereadable(l:colors_json_path)
        echohl ErrorMsg | echom "Pywal colors.json not found. Make sure you have run pywal at least once." | echohl None
        return
    endif

    try
        let l:colors_dict = json_decode(join(readfile(l:colors_json_path), "\n"))
    catch
        echohl ErrorMsg | echom "Error reading colors.json from pywal cache." | echohl None
        return
    endtry

    call themer#apply_pywal_from_dict(l:colors_dict)
    let g:current_color_scheme = "pywal"

    if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
        echom "Pywal colors applied from colors.json."
    endif
endfunction

function! themer#apply_pywal_from_dict(colors_dict)
    execute 'highlight clear'

    let l:bg = a:colors_dict.special.background
    let l:fg = a:colors_dict.special.foreground
    let l:cursor = a:colors_dict.special.cursor

    if g:vim_themer_background ==# "auto"
        let l:brightness = str2nr(matchstr(l:bg, '^#\(\x\{2\}\)'))
        let l:background_setting = (l:brightness < 128 ? "dark" : "light")
    else
        let l:background_setting = g:vim_themer_background
    endif

    try
        execute 'highlight Normal guibg=' . l:bg . ' guifg=' . l:fg
        execute 'highlight Cursor guifg=' . l:bg . ' guibg=' . l:cursor
        execute 'set background=' . l:background_setting
    catch
        echohl ErrorMsg | echom "Error applying background or foreground colors." | echohl None
    endtry

    let l:colors = a:colors_dict.colors

    try
        execute 'highlight Comment guifg=' . l:colors.color8 . ' gui=italic'
        execute 'highlight Constant guifg=' . l:colors.color3
        execute 'highlight Identifier guifg=' . l:colors.color4
        execute 'highlight Statement guifg=' . l:colors.color1
        execute 'highlight PreProc guifg=' . l:colors.color5
        execute 'highlight Type guifg=' . l:colors.color6
        execute 'highlight Special guifg=' . l:colors.color2
        execute 'highlight Underlined guifg=' . l:colors.color12 . ' gui=underline'
        execute 'highlight Todo guifg=' . l:colors.color1 . ' guibg=' . l:colors.color7 . ' gui=bold'
        execute 'highlight Error guifg=' . l:colors.color0 . ' guibg=' . l:colors.color9 . ' gui=bold'
        execute 'highlight LineNr guifg=' . l:colors.color8
        execute 'highlight CursorLineNr guifg=' . l:colors.color12
        execute 'highlight Visual guibg=' . l:colors.color10
        execute 'highlight StatusLine guibg=' . l:colors.color0 . ' guifg=' . l:colors.color7
        execute 'highlight StatusLineNC guibg=' . l:colors.color0 . ' guifg=' . l:colors.color8
        execute 'highlight VertSplit guifg=' . l:colors.color8
    catch
        echohl ErrorMsg | echom "Error applying highlight groups from pywal colors." | echohl None
    endtry
endfunction

function! themer#save_theme()
    if exists('g:current_color_scheme')
        if g:current_color_scheme ==# "pywal"
            let l:colors_json_path = expand('~/.cache/wal/colors.json')
            if filereadable(l:colors_json_path)
                try
                    call writefile([g:current_color_scheme], expand('~/.vim_themer_default'))
                    call writefile(readfile(l:colors_json_path), expand('~/.vim_themer_saved_pywal.json'))
                    if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
                        echom "Pywal theme saved as default with colors from ~/.vim_themer_saved_pywal.json"
                    endif
                catch
                    echohl ErrorMsg | echom "Error saving pywal colors from ~/.cache/wal/colors.json." | echohl None
                endtry
            else
                echohl ErrorMsg | echom "Pywal colors.json not found to save." | echohl None
            endif
        else
            call writefile([g:current_color_scheme], expand('~/.vim_themer_default'))
            if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
                echom "Traditional theme saved: " . g:current_color_scheme
            endif
        endif
    else
        echohl ErrorMsg | echom "No theme is currently active to save." | echohl None
    endif
endfunction

function! themer#apply_saved_theme()
    if g:vim_themer_mode ==# "pywal"
        call themer#apply_pywal()
    elseif filereadable(expand('~/.vim_themer_default'))
        let l:saved_theme = trim(readfile(expand('~/.vim_themer_default'))[0])
        if l:saved_theme ==# "pywal"
            if filereadable(expand('~/.vim_themer_saved_pywal.json'))
                try
                    let l:colors_dict = json_decode(join(readfile(expand('~/.vim_themer_saved_pywal.json')), "\n"))
		    call themer#apply_pywal_from_dict(l:colors_dict)
                    if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
                        echom "Loaded saved pywal theme from ~/.vim_themer_saved_pywal.json"
                    endif
                catch
                    echohl ErrorMsg | echom "Error applying saved pywal theme." | echohl None
                endtry
            else
                echohl ErrorMsg | echom "Saved pywal theme file not found." | echohl None
            endif
        else
            try
                execute 'colorscheme ' . l:saved_theme
                if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
                    echom "Loaded saved traditional theme: " . l:saved_theme
                endif
            catch /^Vim\%((\a\+)\)\=:E185/
                echohl ErrorMsg | echom "Saved traditional colorscheme not found: " . l:saved_theme | echohl None
            catch
                echohl ErrorMsg | echom "Error applying saved traditional theme: " . l:saved_theme | echohl None
            endtry
        endif
    else
        echohl WarningMsg | echom "No saved theme found to apply." | echohl None
    endif
endfunction

function! themer#toggle_background()
    if exists('g:current_color_scheme') && g:current_color_scheme ==# 'pywal'
        if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
            echom "Pywal theme detected, background toggle has no effect."
        endif
    else
        if &background == 'dark'
            set background=light
            if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
                echom "Background set to light"
            endif
        else
            set background=dark
            if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
                echom "Background set to dark"
            endif
        endif
    endif
endfunction

" themer: Core functionality for theme selection and pywal integration

" Show the FZF selector for colorschemes
function! themer#show_selector()
    let colorscheme_dirs = g:vim_themer_dirs
    let colorschemes = []

    " Iterate through each directory and look for colorschemes
    for dir in colorscheme_dirs
        let expanded_dir = expand(dir)
        if isdirectory(expanded_dir)
            " Recursively get all colorscheme files (*.vim) from the directory
            let files = globpath(expanded_dir, '**/*.vim', 0, 1)

            " Iterate through each file and check if it is a valid colorscheme
            for file in files
                let content = join(readfile(file), "\n")
                
                " Check if the file contains one of the typical colorscheme keywords
                if content =~ '\vhighlight|hi\s|link\s|set\s+background='
                    let name = fnamemodify(file, ":t:r")
                    call add(colorschemes, name)
                endif
            endfor
        else
            echohl WarningMsg | echom "Warning: Directory not found - " . expanded_dir | echohl None
        endif
    endfor

    let colorschemes = uniq(sort(colorschemes))

    " If no colorschemes are found, display a message and exit
    if empty(colorschemes)
        echohl ErrorMsg | echom "No colorschemes found." | echohl None
        return
    endif

    " Show the colorschemes in FZF and apply the selected one
    call fzf#run(fzf#wrap({
        \ 'source': colorschemes,
        \ 'sink': function('themer#set_theme')
    \ }))
endfunction

" Apply the selected colorscheme
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

" Apply a pywal-generated colorscheme silently without modifying external settings
function! themer#apply_pywal()
    let colors_json_path = expand('~/.cache/wal/colors.json')
    if !filereadable(colors_json_path)
        echohl ErrorMsg | echom "Pywal colors.json not found. Make sure you have run pywal at least once." | echohl None
        return
    endif

    " Read the colors.json file using Vim's json_decode function
    try
        let colors_dict = json_decode(join(readfile(colors_json_path), "\n"))
    catch
        echohl ErrorMsg | echom "Error reading colors.json from pywal cache." | echohl None
        return
    endtry

    " Apply the colors to Vim
    call themer#apply_pywal_from_dict(colors_dict)

    " Update the current theme variable to pywal
    let g:current_color_scheme = "pywal"

    " Final success message
    if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
        echom "Pywal colors applied from colors.json."
    endif
endfunction

" Apply pywal theme from a saved json dictionary
function! themer#apply_pywal_from_dict(colors_dict)
    " Clear all previous highlight groups to reset any previous theme
    execute 'highlight clear'

    " Set general background and foreground
    let bg = a:colors_dict.special.background
    let fg = a:colors_dict.special.foreground
    let cursor = a:colors_dict.special.cursor

    " Determine background setting
    if g:vim_themer_background ==# "auto"
        let brightness = str2nr(matchstr(bg, '^#\(\x\{2\}\)'))  " Get the red component to determine brightness
        let background_setting = (brightness < 128 ? "dark" : "light")
    else
        let background_setting = g:vim_themer_background
    endif

    try
        execute 'highlight Normal guibg=' . bg . ' guifg=' . fg
        execute 'highlight Cursor guifg=' . bg . ' guibg=' . cursor
        execute 'set background=' . background_setting
    catch
        echohl ErrorMsg | echom "Error applying background or foreground colors." | echohl None
    endtry

    " Use base colors for other highlighting groups to create a complete theme
    let colors = a:colors_dict.colors

    try
        " Apply colors across various highlight groups to fully utilize pywal colors
        execute 'highlight Comment guifg=' . colors.color8 . ' gui=italic'
        execute 'highlight Constant guifg=' . colors.color3
        execute 'highlight Identifier guifg=' . colors.color4
        execute 'highlight Statement guifg=' . colors.color1
        execute 'highlight PreProc guifg=' . colors.color5
        execute 'highlight Type guifg=' . colors.color6
        execute 'highlight Special guifg=' . colors.color2
        execute 'highlight Underlined guifg=' . colors.color12 . ' gui=underline'
        execute 'highlight Todo guifg=' . colors.color1 . ' guibg=' . colors.color7 . ' gui=bold'
        execute 'highlight Error guifg=' . colors.color0 . ' guibg=' . colors.color9 . ' gui=bold'
        execute 'highlight LineNr guifg=' . colors.color8
        execute 'highlight CursorLineNr guifg=' . colors.color12
        execute 'highlight Visual guibg=' . colors.color10
        execute 'highlight StatusLine guibg=' . colors.color0 . ' guifg=' . colors.color7
        execute 'highlight StatusLineNC guibg=' . colors.color0 . ' guifg=' . colors.color8
        execute 'highlight VertSplit guifg=' . colors.color8
    catch
        echohl ErrorMsg | echom "Error applying highlight groups from pywal colors." | echohl None
    endtry
endfunction

" Save the current theme as default (either pywal or selected theme)
function! themer#save_theme()
    if exists('g:current_color_scheme')
        if g:current_color_scheme ==# "pywal"
            " Pywal mode in manual mode - Save a copy of the current pywal JSON file
            let colors_json_path = expand('~/.cache/wal/colors.json')
            if filereadable(colors_json_path)
                try
                    call writefile([g:current_color_scheme], expand('~/.vim_themer_default'))
                    call writefile(readfile(colors_json_path), expand('~/.vim_themer_saved_pywal.json'))
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
            " Traditional colorscheme mode - Save the colorscheme name
            call writefile([g:current_color_scheme], expand('~/.vim_themer_default'))
            if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
                echom "Traditional theme saved: " . g:current_color_scheme
            endif
        endif
    else
        echohl ErrorMsg | echom "No theme is currently active to save." | echohl None
    endif
endfunction

" Apply saved theme on Vim startup
function! themer#apply_saved_theme()
    if g:vim_themer_mode ==# "pywal"
        " Always load the latest pywal colors
        call themer#apply_pywal()
    elseif filereadable(expand('~/.vim_themer_default'))
        let saved_theme = trim(readfile(expand('~/.vim_themer_default'))[0])
        if saved_theme ==# "pywal"
            " Load from the saved pywal JSON file
            if filereadable(expand('~/.vim_themer_saved_pywal.json'))
                try
                    let colors_dict = json_decode(join(readfile(expand('~/.vim_themer_saved_pywal.json')), "\n"))
                    call themer#apply_pywal_from_dict(colors_dict)
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
            " Apply the traditional colorscheme by its name
            try
                execute 'colorscheme ' . saved_theme
                if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
                    echom "Loaded saved traditional theme: " . saved_theme
                endif
            catch /^Vim\%((\a\+)\)\=:E185/
                echohl ErrorMsg | echom "Saved traditional colorscheme not found: " . saved_theme | echohl None
            catch
                echohl ErrorMsg | echom "Error applying saved traditional theme: " . saved_theme | echohl None
            endtry
        endif
    else
        echohl WarningMsg | echom "No saved theme found to apply." | echohl None
    endif
endfunction

function! themer#toggle_background()
    " Check if the current theme is pywal
    if g:current_color_scheme ==# 'pywal'
        " Do nothing for pywal themes when toggling background
        if !exists('g:vim_themer_silent') || g:vim_themer_silent == 0
            echom "Pywal theme detected, background toggle has no effect."
        endif
    else
        " For traditional themes, toggle the background between light and dark
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

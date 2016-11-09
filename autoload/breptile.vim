"=============================================================================
"     File: breptile/autoload/breptile.vim
"  Created: 10/07/2016, 12:29
"   Author: Bernie Roesler
"
"  Description: General autoload functions for breptile plugin
"
"=============================================================================
if exists("g:autoloaded_breptile")
    finish
endif

"-----------------------------------------------------------------------------
"       Public API 
"-----------------------------------------------------------------------------
function! breptile#GetConfig() "{{{
    if exists("b:breptile_tmuxpane") && (strlen(b:breptile_tmuxpane) > 0)
        return 0    " no updates to be made, carry on
    endif

    let b:breptile_tmuxpane = ''

    " If we don't have a pane to use, find one. Prioritize tpgrep over global
    " default set by user
    if g:breptile_usetpgrep && exists("b:breptile_tpgrep_pat")
        call s:FindProgramPane(b:breptile_tpgrep_pat)
    endif

    if strlen(b:breptile_tmuxpane) > 0
        return 0    " We have a pane!
    else
        " error! the user said not to use tpgrep, and we couldn't find a pane
        call s:Warn("breptile#GetConfig() failed to find a pane!")
        return 2    
    endif

endfunction
"}}}
function! breptile#UpdateProgramPane(...) abort "{{{
    if a:0 == 0
        call s:FindProgramPane(b:breptile_tpgrep_pat)
    else
        call s:FindProgramPane(a:1)
    endif

    if strlen(b:breptile_tmuxpane) > 0
        return 0    " We have a pane!
    else
        " error! the user said not to use tpgrep, and we couldn't find a pane
        call s:Warn("breptile#GetConfig() failed to find a pane!")
        return 2    
    endif
endfunction
" }}}
function! breptile#SendRange() range abort "{{{
    if breptile#GetConfig()
        call s:Warn("WARNING: Program '" . &filetype . "' is not running!")
        return
    endif
    let reg_save = @@
    silent execute a:firstline . ',' . a:lastline . 'y'
    call breptile#TmuxSendwithReturn(b:breptile_tmuxpane, s:EscapeText(@@))
    let @@ = reg_save
endfunction
" }}}
function! breptile#SendCount(count) abort "{{{
    if breptile#GetConfig()
        call s:Warn("WARNING: Program '" . &filetype . "' is not running!")
        return
    endif
    let reg_save = @@
    silent execute 'normal! ' . a:count . 'yy'
    call breptile#TmuxSendwithReturn(b:breptile_tmuxpane, s:EscapeText(@@))
    let @@ = reg_save
endfunction
" }}}
function! breptile#RunScript(...) abort "{{{
    " Check if program is running!
    if !exists('b:breptile_tmuxpane') || (strlen(b:breptile_tmuxpane) == 0)
        call s:Warn("Program '" . &filetype . "' is not running!")
        return -1
    end

    " If we have an argument, use it as the filename to be run
    if a:0
        let l:filename = a:1
    else
        " use current buffer (expand to full file path)
        let l:filename = expand("%:p")
    endif

    " Use the calling program's command
    let l:com = b:breptile_program_start 
                \ . l:filename
                \ . b:breptile_program_end
    call breptile#TmuxSendwithReturn(b:breptile_tmuxpane, l:com)
endfunction
"}}}
function! breptile#TmuxSend(pane, text) abort "{{{
    " Send command NOT literally, do not send carriage return
    let com = "tmux send-keys -t '" . a:pane . "' " . shellescape(a:text)
    call system(com)
endfunction
"}}}
function! breptile#TmuxSendwithReturn(pane, text) abort "{{{
    " Send command literally, and then send carriage return keystroke
    let litkeys = "tmux send-keys -t '" . a:pane . "' -l " . shellescape(a:text)
    let creturn = "tmux send-keys -t '" . a:pane . "' C-m"
    call system(litkeys . ' && ' . creturn)
endfunction
"}}}

"-----------------------------------------------------------------------------
"       Private API 
"-----------------------------------------------------------------------------
function! s:FindProgramPane(breptile_tpgrep_pat) abort "{{{
    if strlen(a:breptile_tpgrep_pat) == 0
        call s:Warn("WARNING: b:breptile_tpgrep_pat is empty!")
        return
    endif

    " TODO add option to search within session
    " TODO search with other tmux servers (tmux -L ...), or (tmux -L default)
    " [:-2] strips newline returned by 'system'
    " Get current window ID:
    let l:tmux_window = system("tmux display-message -p ''#{window_id}''")[:-2]

    " Include pattern to match time, so user only has to grep for program name
    let l:pat = "'[0-9]:[0-9]{2}.[0-9]{2} " . a:breptile_tpgrep_pat . "'"
    " Search within window:
    " let l:syscom = 'tpgrep -t ' . l:tmux_window . ' ' . l:pat
    " Search within session:
    let l:syscom = 'tpgrep -s -t ' . l:tmux_window . ' ' . l:pat
    let b:breptile_tmuxpane = system(l:syscom)[:-2]

    " Error checking
    if b:breptile_tmuxpane[:4] ==# "Usage"
        echoe "tpgrep error!"
    endif
endfunction
"}}}
function! s:EscapeText(text) abort "{{{
    let l:text = a:text
    " may only need for matlab:
    let l:text = substitute(l:text, ';', '; ', 'g') 
    " Escape '%' so vim doesn't insert filename
    let l:text = substitute(l:text, '%', '\%', 'g')
    let l:text = substitute(l:text, "\n", "\<CR>", 'g')

    return l:text
endfunction
"}}}
function! s:SendOp(type) abort "{{{
    if breptile#GetConfig()
        call s:Warn("WARNING: Program '" . &filetype . "' is not running!")
        return
    endif

    " Selection needs to include start and end points 
    let sel_save = &selection
    let &selection = "inclusive"
    " function will wipe out unnamed register, so save its contents
    let reg_save = @@

    " copy motion for type (see :help g@)
    if (a:type ==# 'v') || (a:type ==# 'V')
        silent execute "normal! gvy"
    elseif a:type ==# 'char'
        silent execute "normal! `[v`]y"
    elseif a:type ==# 'line'
        silent execute "norma! '[V']y"
    else
        " ignore block-visual '<C-v>' 
        return  
    endif

    call breptile#TmuxSendwithReturn(b:breptile_tmuxpane, s:EscapeText(@@))

    " Return selection and unnamed register to previous values
    let &selection = sel_save
    let @@ = reg_save
endfunction
"}}}
function! s:Warn(str) abort "{{{
    echohl WarningMsg | echom a:str | echohl None
    return
endfunction
"}}}

"-----------------------------------------------------------------------------
"        Create <Plug> for user mappings
"-----------------------------------------------------------------------------
" Send text operator{{{
noremap <silent> <Plug>BReptileSendOpNorm :set operatorfunc=<SID>SendOp<CR>g@
noremap <silent> <Plug>BReptileSendOpVis  :<C-u>call <SID>SendOp(visualmode())<CR>
"}}}
" Run script -- how do I make a command that links to this <Plug>?
" noremap <silent> <Plug>BReptileRunScript :<C-u>call <SID>RunScript(<q-args>)<CR>

let g:autoloaded_breptile = 1
"=============================================================================
"=============================================================================

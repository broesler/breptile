"=============================================================================
"     File: breptile.vim
"  Created: 09/15/2016, 19:26
"   Author: Bernie Roesler
"
"  Description: Functions for running commands/scripts in any tmux pane
"
"=============================================================================
" if exists('g:loaded_breptile') || &cp
"   finish
" endif

"-----------------------------------------------------------------------------
"       Configuration 
"-----------------------------------------------------------------------------
if !exists("g:buf_file")
    let g:buf_file = '/tmp/breptile_paste.txt'
endif

"-----------------------------------------------------------------------------
"       Tmux  
"-----------------------------------------------------------------------------
" TmuxSend commands {{{
function! TmuxSend(text, pane)
    " Append a carriage return so command gets entered in other pane
    if a:text[-1] != "\<CR>"
        let l:text = a:text . "\<CR>"
    endif

    call s:WriteBufFile(l:text)

    let l:syscom = "tmux load-buffer " . shellescape(g:buf_file) 
    call system(l:syscom)

    let l:syscom = "tmux paste-buffer -d -t " . shellescape(a:pane) 
    call system(l:syscom)

    call system("rm -f " . shellescape(g:buf_file))
endfunction
"}}}

"-----------------------------------------------------------------------------
"       Utilities 
"-----------------------------------------------------------------------------
" WritePasteFile of commands {{{
function! s:WriteBufFile(text)
    call system("cat > " . g:buf_file, a:text)
endfunction
"}}}
" BreptileGetConfig {{{
function! s:BreptileGetConfig(tpgrep_pat)
    if exists("b:breptile_tmuxpane") || !b:breptile_tmuxpane
        return
    endif

    " Find appropriate program's pane
    call s:FindProgramPane(a:tpgrep_pat)

    if exists("g:breptile_default_tmuxpane") && !b:breptile_tmuxpane
        let b:breptile_tmuxpane = g:breptile_default_tmuxpane
        return
    endif
endfunction
"}}}
" FindProgramPane of command {{{
function! s:FindProgramPane(tpgrep_pat)
    " Check if we are running tmux
    if strlen($TMUX) > 0 
        " system() returns a list, so strip the trailing newline (only take up to
        " the 2nd to last character)
        let l:tmux_window = system("tmux display-message -p ''#{window_id}''")[:-2]

        " Add pattern to match time, so user only has to grep for program name
        let l:pat = "'[0-9]:[0-9]{2}.[0-9]{2} " . a:tpgrep_pat . "'"
        let l:syscom = 'tpgrep -t ' . l:tmux_window . ' ' . l:pat
        let b:breptile_tmuxpane = system(l:syscom)[:-2]

        " Error checking
        if b:breptile_tmuxpane[:4] ==# "Usage"
            let b:breptile_tmuxpane = ''
            echoe "tpgrep error!"
        endif
    else 
        let b:breptile_tmuxpane  = '' 
    endif
endfunction
"}}}

let g:loaded_gnuplotvim = 1
"=============================================================================
"=============================================================================

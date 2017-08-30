"=============================================================================
"     File: breptile/ftplugin/matlab/debug.vim
"  Created: 10/06/2016, 15:04
"   Author: Bernie Roesler
"
"  Description: Debugging functions for matlab files
"
"=============================================================================
if exists('g:loaded_breptile_matlab_debug')
    finish
endif

" Define signs for debugging stops {{{
hi clear SignColumn
hi default DebugStopHL ctermfg=darkred
hi link DebugCursorHL Search
sign define dbstop text=$$ texthl=DebugStopHL
sign define piet   text=>> texthl=DebugCursorHL
"}}}
function! matlab#debug#Dbstop() "{{{
    write %
    let l:lnr = line('.')
    let l:mcom = "dbstop in " . expand("%") . " at " . l:lnr
    BRTmuxSend l:mcom
    " place sign at dbstop current line, use lnr as ID
    exe ":silent sign place " . l:lnr . " line=" . l:lnr 
                \. " name=dbstop file=" . expand("%:p")
    " keep file from being modified during debugging
    " NOTE: Comment out for now... it's annoying and I know how it works
    " set noma
endfunction
"}}}
function! matlab#debug#Dbclear() "{{{
    let l:mcom = "dbclear in " . expand("%") . " at " . line(".")
    BRTmuxSend l:mcom
    silent! sign unplace
endfunction
"}}}
function! matlab#debug#Dbclearall() "{{{
    BRTmuxSend 'dbclear all'
    silent! sign unplace *
    set ma
endfunction
"}}}
function! matlab#debug#Dbcont() "{{{
    " Continue running from breakpoint
    BRTmuxSend dbcont
endfunction
function! matlab#debug#Dbquit() "{{{
    " Send dbquit to matlab
    BRTmuxSend dbquit
    silent! sign unplace 1
    set ma
endfunction
"}}}
function! matlab#debug#Dbquitall() "{{{
    " Send dbquit to matlab and remove sign
    BRTmuxSend 'dbquit all'
    silent! sign unplace 1
    set ma
endfunction
"}}}
function! matlab#debug#Dbstatus() "{{{
    " Show all debugging stops
    BRTmuxSend dbstatus
endfunction
"}}}
function! matlab#debug#Dbstep() "{{{
    silent! sign unplace 1
    BRTmuxSend dbstep

    " Return line on which debugger has stopped
    "    Read MATLAB window debugger output i.e.:
    "      37      f1 = f(z(:,:,i));
    "      K>> dbstep
    "      38      f2 = f(z(:,:,i)+(h/2)*f1);
    "      K>>
    "    and grep for lines starting with numbers, then read last number
    let lnr = system('tmux capture-pane -p -t ''' . b:breptile_tmuxpane . ''' | grep -o "^\<[0-9]\+\>" | tail -n 1')

    " " move cursor to next line, first column with non-whitespace character
    " call cursor(lnr,0) | norm! ^
    exe ":silent! sign place 1 line=" . lnr . " name=piet file=" . expand("%:p")
endfunction
"}}}

let g:loaded_breptile_matlab_debug = 1
" vim:fdm=marker
"=============================================================================
"=============================================================================

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
    let lnr = line('.')
    let mcom = "dbstop in " . expand("%") . " at " . lnr
    call system('ts -t ''' . b:breptile_tmuxpane . ''' ' . mcom)
    " place sign at dbstop current line, use lnr as ID
    exe ":silent sign place " . lnr . " line=" . lnr . " name=dbstop file=" . expand("%:p")
    " keep file from being modified during debugging
    set noma
endfunction
"}}}
function! matlab#debug#Dbclear() "{{{
    let mcom = "dbclear in " . expand("%") . " at " . line(".")
    call system('ts -t ''' . b:breptile_tmuxpane . ''' ' . mcom)
    silent! sign unplace
endfunction
"}}}
function! matlab#debug#Dbclearall() "{{{
    call system('ts -t ''' . b:breptile_tmuxpane . ''' dbclear all')
    silent! sign unplace *
    set ma
endfunction
"}}}
function! matlab#debug#Dbquit() "{{{
    " Send dbquit to matlab
    call system('ts -t ''' . b:breptile_tmuxpane . ''' dbquit')

    " Remove debugging cursor marker
    silent! sign unplace 1

    " Make file modifiable again
    set ma
endfunction
"}}}
function! matlab#debug#Dbquitall() "{{{
    " Send dbquit to matlab
    call system('ts -t ''' . b:breptile_tmuxpane . ''' dbquit all')

    " Remove debugging cursor marker
    silent! sign unplace 1

    " Make file modifiable again
    set ma
endfunction
"}}}
function! matlab#debug#Dbstep() "{{{
    " Unplace sign at current cursor position
    silent! sign unplace 1

    " Make debugging step
    call system('ts -t ''' . b:breptile_tmuxpane . ''' dbstep')

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

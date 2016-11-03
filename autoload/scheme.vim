"=============================================================================
"     File: scheme.vim
"  Created: 11/02/2016, 16:04
"   Author: Bernie Roesler
"
"  Description: Scheme utility functions
"
"=============================================================================
if exists('g:loaded_breptile_scheme_util')
    finish
endif

function! scheme#SchemeCd() "{{{
    " Use cd('full path') form to deal with spaces, etc. in filenames
    let mcom = '(cd "' . expand("%:p:h") . '")'
    call breptile#TmuxSendwithReturn(b:breptile_tmuxpane, mcom)
endfunction
"}}}
function! scheme#SchemeQuit() "{{{
    " Send C-c, C-m, C-c to "Quit!" back to top-level REPL (in rlwrap mode)
    " Send non-literal keys so they are interpreted as the proper signals
    call breptile#TmuxSend(b:breptile_tmuxpane, 'C-c')
    call breptile#TmuxSend(b:breptile_tmuxpane, 'C-m')
    call breptile#TmuxSend(b:breptile_tmuxpane, 'C-c')
endfunction
"}}}
function! scheme#SchemeAbort() "{{{
    " Send C-c, C-x to "Abort!" current command
    " Send non-literal keys so they are interpreted as the proper signals
    call breptile#TmuxSend(b:breptile_tmuxpane, 'C-c')
    call breptile#TmuxSend(b:breptile_tmuxpane, 'C-x')
endfunction
"}}}
function! scheme#SchemeClear() "{{{
    " Send C-c, C-l to "Clear!" current command
    " Send non-literal keys so they are interpreted as the proper signals
    call breptile#TmuxSend(b:breptile_tmuxpane, 'C-c')
    call breptile#TmuxSend(b:breptile_tmuxpane, 'C-l')
endfunction
"}}}

let g:loaded_breptile_scheme_util = 1
" vim:fdm=marker

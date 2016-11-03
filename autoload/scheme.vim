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
    call system('ts -t ''' . b:breptile_tmuxpane . ''' ' . shellescape(mcom))
endfunction
"}}}
function! scheme#SchemeQuit() "{{{
    call system('ts -t ''' . b:breptile_tmuxpane . ''' ' . shellescape(mcom))
endfunction
"}}}


let g:loaded_breptile_scheme_util = 1
" vim:fdm=marker

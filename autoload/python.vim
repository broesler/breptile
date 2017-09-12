"=============================================================================
"     File: autoload/python.vim
"  Created: 08/29/2017, 22:43
"   Author: Bernie Roesler
"
"  Description: utilities for using vim with the python interpreter
"
"=============================================================================
" if exists('g:loaded_breptile_python_util')
"     finish
" endif

function! python#PythonRunI() "{{{
    " Run python script interactively
    BRTmuxSend 'python -i ''' . expand("%") . ''''
endfunction
"}}}
function! python#PythonDbstop() "{{{
    " Set a debugging breakpoint for use with pdb
    normal! Oimport pdb; pdb.set_trace()j
endfunction
"}}}
let g:loaded_breptile_python_util = 1
" vim:fdm=marker

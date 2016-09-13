"=============================================================================
"     File: make.vim
"  Created: 09/12/2016, 22:26
"   Author: Bernie Roesler
"
"  Description: Functions for running gnuplot scripts in the CLI
"
"=============================================================================
if !exists("g:gnuplot_command")
  let g:gnuplot_command = "gnuplot -p -e"
endif

function! GnuplotRunFile()
  silent !clear
  execute "!" . g:gnuplot_command . " " . bufname("%")
endfunction

nnoremap <buffer> <localleader>m :call GnuplotRunFile()<CR>

"=============================================================================
"=============================================================================

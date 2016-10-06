"=============================================================================
"     File: make.vim
"  Created: 09/12/2016, 22:26
"   Author: Bernie Roesler
"
"  Description: Functions for running gnuplot scripts in the CLI
"
"=============================================================================
" TODO move this function to a generic breptile function
function! s:GnuplotRunFile()
    " Error looks like:
    "   set itle 'Simple Plots'
    "       ^
    "   "simple_1_gnuplot.gpi", line 7: unrecognized option - see 'help set'.
    let &l:errorformat="%E%p^,%Z\"%f\"\\, line %l:%m"
    let &l:makeprg = g:gnuplot_command . " " . bufname("%")

    " Don't jump to first error
    write | silent make! | redraw!
endfunction

noremap <silent> <Plug>BReptileGnuplotrunfile :<C-u>call <SID>GnuplotRunFile()<CR>

" User puts this mapping in their vimrc:
nmap <buffer> <localleader>M <Plug>BReptileGnuplotrunfile

"=============================================================================
"=============================================================================

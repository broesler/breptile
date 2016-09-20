"=============================================================================
"     File: make.vim
"  Created: 09/12/2016, 22:26
"   Author: Bernie Roesler
"
"  Description: Functions for running gnuplot scripts in the CLI
"
"=============================================================================

if !exists("g:gnuplot_defaultoptions")
    let g:gnuplot_defaultoptions = "-p"
endif

if !exists("g:gnuplot_command")
    if executable('gnuplot')
        let g:gnuplot_command = "gnuplot"
    else
        finish
    endif
    let g:gnuplot_command .= " " . g:gnuplot_defaultoptions
endif

" Directly set pane if it exists and is non-empty
if exists("g:gnuplot_pane") && g:gnuplot_pane
    let b:breptile_tmuxpane = g:gnuplot_pane
endif

" Search pattern for gnuplot pane
if !exists("b:tpgrep_pat")
    let b:tpgrep_pat = '[g]nuplot'
endif

function! s:GnuplotRunFile()
    " Error looks like:
    "   set itle 'Simple Plots'
    "       ^
    "   "simple_1_gnuplot.gpi", line 7: unrecognized option - see 'help set'.
    let &l:errorformat="%E%p^,%Z\"%f\"\\, line %l:%m"
    let &l:makeprg = g:gnuplot_command . " " . bufname("%")

    write | silent make | redraw!
endfunction

noremap <silent> <Plug>BReptileGnuplotrunfile :<C-u>call <SID>GnuplotRunFile()<CR>

" User puts this mapping in their vimrc:
nmap <buffer> <localleader>M <Plug>BReptileGnuplotrunfile

"=============================================================================
"=============================================================================

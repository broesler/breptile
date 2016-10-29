"=============================================================================
"     File: main.vim
"  Created: 09/14/2016, 16:11
"   Author: Bernie Roesler
"
"  Description: Buffer settings for gnuplot files
"
"=============================================================================
" Configuration {{{
" Gnuplot script-running command
let b:breptile_program_start = get(g:, "g:breptile_gnuplot_program_start", "load '")
let b:breptile_program_end   = get(g:, "g:breptile_gnuplot_program_end"  , "'")

" Directly set pane if it exists and is non-empty
if exists("g:gnuplot_pane") && strlen("g:gnuplot_pane") > 0
    let b:breptile_tmuxpane = g:gnuplot_pane
endif

" Search pattern for gnuplot pane
let b:breptile_tpgrep_pat = get(g:, 'breptile_tpgrep_pat_gnuplot', '[g]nuplot')

" Gnuplot error looks like:
"   set itle 'Simple Plots'
"       ^
"   "simple_1_gnuplot.gpi", line 7: unrecognized option - see 'help set'.
let b:gnuplot_errorformat="%E%p^,%Z\"%f\"\\, line %l:%m"
" let b:gnuplot_makeprg = g:gnuplot_command . " " . bufname("%")
" Need to use gnuplot> load "filename.gpi"
let b:gnuplot_makeprg = 'load "' . expand("%:t") . '"'

"}}}
" Buffer-local settings {{{
setlocal tabstop=4            " tabs every 4 spaces
setlocal softtabstop=4        " let backspace delete indent
setlocal shiftwidth=4
setlocal textwidth=80
setlocal iskeyword-=:         " colon is NOT part of keywords
setlocal formatoptions-=t     " do not auto-wrap code, only comments

setlocal comments=:#
setlocal commentstring=#%s

setlocal foldmethod=indent
setlocal foldnestmax=4
setlocal foldignore=
setlocal foldminlines=3

setlocal nowrap
"}}}
" Mappings {{{
" Make line into a comment header with dashes
" nnoremap <buffer> <LocalLeader>h :MyCommentBlock # -<CR>
" }}}
"=============================================================================
"=============================================================================

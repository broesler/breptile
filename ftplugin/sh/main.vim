"=============================================================================
"     File: breptile/ftplugin/sh/main.vim
"  Created: 10/07/2016, 20:35
"   Author: Bernie Roesler
"
"  Description: Settings for shell scripts
"
"=============================================================================
" Configuration "{{{
" Gnuplot script-running command
let b:breptile_program = get(g:, "g:breptile_bash_program", "./")

" Directly set pane if it exists and is non-empty
if exists("g:breptile_bash_pane") && strlen("g:breptile_bash_pane") > 0
    let b:breptile_tmuxpane = g:breptile_bash_pane
endif

" Search pattern for gnuplot pane
let b:breptile_tpgrep_pat = get(g:, 'breptile_tpgrep_pat_bash', '/[u]sr/local/bin/bash')

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
"=============================================================================
"=============================================================================

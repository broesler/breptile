"=============================================================================
"     File: settings.vim
"  Created: 09/14/2016, 16:11
"   Author: Bernie Roesler
"
"  Description: Buffer settings for gnuplot files
"
"=============================================================================
if exists("g:loaded_breptile_gnuplot_settings")
    finish
endif

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
let b:tpgrep_pat = get(b:, 'tpgrep_pat', '[g]nuplot')

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

let g:loaded_breptile_gnuplot_settings = 1
"=============================================================================
"=============================================================================

"=============================================================================
"     File: settings.vim
"  Created: 09/14/2016, 16:11
"   Author: Bernie Roesler
"
"  Description: Buffer settings for gnuplot files
"
"=============================================================================
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

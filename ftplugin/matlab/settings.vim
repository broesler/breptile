"=============================================================================
"     File: settings.vim
"  Created: 09/16/2016, 15:03
"   Author: Bernie Roesler
"
"  Description: Matlab filetype settings
"
"=============================================================================
if exists('g:loaded_breptile_matlab_settings')
    finish
endif

"-----------------------------------------------------------------------------
"       Configuration  {{{
"-----------------------------------------------------------------------------
if exists("g:matlab_pane") && g:matlab_pane
    let b:breptile_tmuxpane = g:matlab_pane
endif

if !exists("g:breptile_mapkeys_matlab")
    let g:breptile_mapkeys_matlab = 0
endif

" Search pattern for gnuplot pane
" let b:tpgrep_pat = get(b:, 'tpgrep_pat', '/Applications/[M]ATLAB')
let b:tpgrep_pat = get(b:, 'tpgrep_pat', '[r]lwrap.*matlab')

"}}}--------------------------------------------------------------------------
"        Buffer-local settings {{{
"-----------------------------------------------------------------------------
setlocal tabstop=4            " tabs every 4 spaces
setlocal softtabstop=0        " let backspace delete indent
setlocal shiftwidth=4
setlocal textwidth=80
setlocal iskeyword-=:         " colon is NOT part of keywords
setlocal formatoptions-=t     " do not auto-wrap code, only comments

setlocal comments=:%
setlocal commentstring=%%%s

setlocal foldlevelstart=0     " all folds open to start
setlocal foldmethod=indent
setlocal foldnestmax=4
setlocal foldignore=
setlocal foldminlines=3

setlocal nowrap
"}}}

let g:loaded_breptile_matlab_settings = 1
"=============================================================================
"=============================================================================

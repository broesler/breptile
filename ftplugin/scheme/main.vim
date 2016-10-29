"=============================================================================
"     File: main.vim
"  Created: 09/14/2016, 16:11
"   Author: Bernie Roesler
"
"  Description: Buffer settings for scheme files
"
"=============================================================================
" Configuration {{{
" scheme script-running command
let b:breptile_program_start = get(g:, "g:breptile_scheme_program_start", "(load \"")
let b:breptile_program_end   = get(g:, "g:breptile_scheme_program_end",   "\")")

" Directly set pane if it exists and is non-empty
if exists("g:scheme_pane") && strlen("g:scheme_pane") > 0
    let b:breptile_tmuxpane = g:scheme_pane
endif

" Search pattern for scheme pane
let b:breptile_tpgrep_pat = get(g:, 'breptile_tpgrep_pat_scheme', '[s]cheme')
" let b:breptile_tpgrep_pat = get(g:, 'breptile_tpgrep_pat_scheme', '[r]lwrap.*scheme')

"}}}
" Buffer-local settings {{{
setlocal tabstop=4            " tabs every 4 spaces
setlocal softtabstop=4        " let backspace delete indent
setlocal shiftwidth=4
setlocal textwidth=80
setlocal iskeyword-=:         " colon is NOT part of keywords
setlocal formatoptions-=t     " do not auto-wrap code, only comments

setlocal comments=:;
setlocal commentstring=;%s

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

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

"}}}--------------------------------------------------------------------------
"       Commands and Keymaps {{{
"-----------------------------------------------------------------------------
command! -buffer -bar SchemeCd      :call scheme#SchemeCd()
command! -buffer -bar SchemeQuit    :call scheme#SchemeQuit()
command! -buffer -bar SchemeAbort   :call scheme#SchemeAbort()
command! -buffer -bar SchemeClear   :call scheme#SchemeClear()

" Commands to control Scheme REPL
nnoremap <buffer> <localleader>d :SchemeCd<CR>
nnoremap <buffer> <localleader>C :SchemeQuit<CR>
nnoremap <buffer> <localleader>X :SchemeAbort<CR>
nnoremap <buffer> <localleader>l :SchemeClear<CR>

" Evaluate current expression
if g:breptile_mapkeys
    " Allow recursive mapping to use operator function
    nmap <localleader><CR> <localleader>ea(
endif
"=============================================================================
"=============================================================================

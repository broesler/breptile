"=============================================================================
"     File: breptile/ftplugin/matlab.vim
"   Author: Bernie Roesler
"  Created: 12/07/15, 12:27
"
" Last Modified: 05/16/2016, 10:10
"
"  Description: MATLAB filetype settings and mappings
"=============================================================================

"-----------------------------------------------------------------------------
"       Configuration  {{{
"-----------------------------------------------------------------------------
" Matlab script-running command
let b:breptile_runfmt = get(g:, "g:breptile_matlab_runfmt", "run '%s'")

if exists("g:matlab_pane") && strlen("g:matlab_pane") > 0
    let b:breptile_tmuxpane = g:matlab_pane
endif

if !exists("g:breptile_mapkeys_matlab")
    let g:breptile_mapkeys_matlab = 0
endif

" Search pattern for gnuplot pane
let b:breptile_tpgrep_pat = get(g:, 'breptile_tpgrep_pat_matlab', '/Applications/[M]ATLAB')

" Matlab EFM
let b:matlab_errorformat="%WWarning: %m,%Z> in %f (line %l),"
            \ . "%ZError in %f (line %l),%+EError using%.%#,%C%m,%-G%.%#"
" \ . "%EError: File: %f Line: %l Column: %c,%Z%m"

"}}}--------------------------------------------------------------------------
"       Commands and Keymaps {{{
"-----------------------------------------------------------------------------

command! -buffer -bar MatlabCd         :call matlab#util#MatlabCd()
command! -buffer -bar MatlabLintScript :call matlab#util#MatlabLintScript()
command! -buffer -bar MatlabDbstop     :call matlab#debug#Dbstop()
command! -buffer -bar MatlabDbclear    :call matlab#debug#Dbclear()
command! -buffer -bar MatlabDbclearall :call matlab#debug#Dbclearall()
command! -buffer -bar MatlabDbcont     :call matlab#debug#Dbcont()
command! -buffer -bar MatlabDbquit     :call matlab#debug#Dbquit()
command! -buffer -bar MatlabDbquitall  :call matlab#debug#Dbquitall()
command! -buffer -bar MatlabDbstatus   :call matlab#debug#Dbstatus()
command! -buffer -bar MatlabDbstep     :call matlab#debug#Dbstep()

if g:breptile_mapkeys_matlab "{{{
    " TODO move these 'ts -t' maps to functions using "TmuxSend" (and make
    " that function globally available, for generally sending it)
    " Syntax checking:
    nnoremap <buffer> <localleader>L :MatlabLintScript<CR>

    " Debugging
    nnoremap <buffer> <localleader>b :MatlabDbstop<CR>
    nnoremap <buffer> <localleader>S :MatlabDbstatus<CR>
    nnoremap <buffer> <localleader>c :MatlabDbclear<CR>
    nnoremap <buffer> <localleader>C :MatlabDbclearall<CR>
    nnoremap <buffer> <localleader>q :MatlabDbquit<CR>
    nnoremap <buffer> <localleader>n :MatlabDbstep<CR>
    nnoremap <buffer> <localleader>Q :MatlabDbquitall<CR>
    nnoremap <buffer> <localleader>r :MatlabDbcont<CR>

    " Call Matlab help on current word, or whos on variable
    " TODO include 'whodat.m' in package
    nnoremap <silent> <buffer> <localleader>h :BRTmuxSend "help <C-R><C-W>"<CR>
    nnoremap <silent> <buffer> <localleader>w :BRTmuxSend "whodat <C-R><C-W>"<CR>
    nnoremap <silent> <buffer> <localleader>w :BRTmuxSend whodat<CR>
    " Standard usage:
    " nnoremap <silent> <buffer> <localleader>w :BRTmuxSend "whos <C-R><C-W>"<CR>
    " nnoremap <silent> <buffer> <localleader>w :BRTmuxSend whos<CR>

    " display variable in console
    nnoremap <buffer> <localleader><CR> :BRTmuxSend "<C-R><C-W>"<CR>

    " Change matlab directory
    nnoremap <buffer> <localleader>d :MatlabCd<CR>
endif
"}}}
"}}}

"=============================================================================
"=============================================================================

"=============================================================================
"     File: ftplugin/python.vim
"  Created: 08/29/2017, 20:49
"   Author: Bernie Roesler
"
"  Description: Buffer settings for python files
"
"=============================================================================
" Configuration {{{
" python script-running command
let b:breptile_runfmt = get(g:, "g:breptile_python_runfmt", "python '%s'")

" Directly set pane if it exists and is non-empty
if exists("g:python_pane") && strlen("g:python_pane") > 0
    let b:breptile_tmuxpane = g:python_pane
endif

" Search pattern for python pane
let b:breptile_tpgrep_pat = get(g:, 'breptile_tpgrep_pat_python', '[p]ython')
"}}}-------------------------------------------------------------------------- 
"        " Commands and Keymaps {{{
"-----------------------------------------------------------------------------
command! -buffer -bar BRPythonRunI :call python#PythonRunI() 
command! -buffer -bar BRPythonDbstop :call python#PythonDbstop() 

if g:breptile_mapkeys_python "{{{
    nnoremap <buffer> <localleader>I :BRPythonRunI<CR>
    nnoremap <buffer> <localleader>b :BRPythonDbstop<CR>
endif
"}}}

" }}}
"=============================================================================
"=============================================================================

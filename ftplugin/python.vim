"=============================================================================
"     File: ftplugin/python.vim
"  Created: 08/29/2017, 20:49
"   Author: Bernie Roesler
"
"  Description: Buffer settings for python files
"
"=============================================================================
" Configuration {{{
if exists("g:breptile_python_useinterp") && g:breptile_python_useinterp == 1
    " Search for python interpreter pane
    let b:breptile_tpgrep_pat = get(g:, 'breptile_tpgrep_pat_python', 'i?python')
    " Python code to run a script in the interpreter
    " let b:breptile_runfmt = "with open('%s', 'r') as f:\n    exec(f.read())\n"
    let b:breptile_runfmt = "%%run '%s'"
else " just use shell
    let g:python_pane = 'bottom-left'       
    let b:breptile_runfmt = "python '%s'"
endif

" Run format and pane can still be overridden by user
let b:breptile_runfmt = get(g:, "g:breptile_python_runfmt", b:breptile_runfmt)

" Directly set pane if it exists and is non-empty
if exists("g:python_pane") && strlen("g:python_pane") > 0
    let b:breptile_tmuxpane = g:python_pane
endif

"}}}-------------------------------------------------------------------------- 
"        " Commands and Keymaps {{{
"-----------------------------------------------------------------------------
command! -buffer -bar PythonCd     :call python#PythonCd()
command! -buffer -bar PythonRunI   :call python#PythonRunI() 
command! -buffer -bar PythonDbstop :call python#PythonDbstop() 

if g:breptile_mapkeys_python "{{{
    " Change to current directory
    nnoremap <buffer> <LocalLeader>d :PythonCd<CR>
    nnoremap <buffer> <LocalLeader>I :PythonRunI<CR>

    " Debugging
    nnoremap <buffer> <LocalLeader>b :PythonDbstop<CR>

    " Get help!
    nnoremap <silent> <buffer> <localleader>h :BRTmuxSend 'help(''<C-R><C-W>'')'<CR>
    nnoremap <silent> <buffer> <localleader>? :BRTmuxSend '<C-R><C-W>?'<CR>
    nnoremap <buffer> <LocalLeader>W :BRTmuxSend '%who'<CR>

    " TODO Mappings for:
    "   -- (myword)??
    " TODO function to call help on visual mode selection (i.e. gevent.spawn)
endif
"}}}

" }}}
"=============================================================================
"=============================================================================

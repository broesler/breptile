"=============================================================================
"     File: ftplugin/python.vim
"  Created: 08/29/2017, 20:49
"   Author: Bernie Roesler
"
"  Description: Buffer settings for python files
"
"=============================================================================
" Configuration {{{
call python#PythonConfig()

if !exists('g:breptile_mapkeys_python')
    let g:breptile_mapkeys_python = 1
endif

"}}}--------------------------------------------------------------------------
"        " Commands and Keymaps {{{
"-----------------------------------------------------------------------------
command! -buffer PythonUseShell :call python#UseShell()

command! -buffer -bar PythonCd :call python#PythonCd()

command! -buffer PythonRunI   :call python#PythonRunI()
command! -buffer PythonDbstop :call python#PythonDbstop()
command! -buffer -bang PythonDebug  :call python#PythonDebug(<bang>0)

command! -buffer PythonRunTests :call python#PythonRunTests()

if g:breptile_mapkeys_python "{{{
    " Change to current directory
    nnoremap <buffer> <LocalLeader>d :PythonCd<CR>

    " Debugging
    nnoremap <buffer> <LocalLeader>b :PythonDbstop<CR>
    nnoremap <buffer> <LocalLeader>D :PythonDebug<CR>
    nnoremap <buffer> <LocalLeader>I :PythonRunI<CR>

    nnoremap <buffer> <LocalLeader>T :PythonRunTests<CR>

    " Variable info
    nnoremap <buffer> <LocalLeader>W :BRTmuxSend '%whos'<CR>

    " Get help!
    nnoremap <silent> <buffer> <localleader>h :BRTmuxSend 'help(''<C-R><C-W>'')'<CR>
    nmap <silent> <localleader>? <Plug>PyHelpNorm
    vmap <silent> <localleader>? <Plug>PyHelpVis
endif
"}}}

"}}}
"=============================================================================
"=============================================================================

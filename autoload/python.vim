"=============================================================================
"     File: autoload/python.vim
"  Created: 08/29/2017, 22:43
"   Author: Bernie Roesler
"
"  Description: utilities for using vim with the python interpreter
"
"=============================================================================
" if exists('g:loaded_breptile_python_util')
"     finish
" endif

"----------------------------------------------------------------------------- 
"       Public API 
"-----------------------------------------------------------------------------
function! python#PythonConfig()
    " Determine whether to use python interpreter or not:
    "   0 == no interpreter, 1 == python, 2 == ipython
    let g:breptile_python_interp = get(g:, 'breptile_python_interp', 0)
    let b:breptile_tpgrep_pat = get(g:, 'breptile_tpgrep_pat_python', 'i?python')

    if g:breptile_python_interp > 0
        if g:breptile_python_interp == 1
            let b:breptile_runfmt = "with open('%s', 'r') as f:\n    exec(f.read())\n"
        else " if g:breptile_python_interp == 2
            let b:breptile_runfmt = "%%run '%s'"
        endif
    else " just use shell
        " Get python version consistent with vim
        if has('pythonx')
            pythonx import vim;
                \ from sys import version_info as v;
                \ vim.command('let python_version=%d' % (v[0]))
        else
            let python_version=3
        endif
        let g:python_pane = 'bottom-left'
        let b:breptile_runfmt = 'python' . python_version . " '%s'"
    endif

    " Run format and pane can still be overridden by user
    let b:breptile_runfmt = get(g:, 'breptile_python_runfmt', b:breptile_runfmt)

    " Directly set pane if it exists and is non-empty
    if exists('g:python_pane') && strlen('g:python_pane') > 0
        let b:breptile_tmuxpane = g:python_pane
    endif
endfunction

function! python#PythonCd()
    " TODO take dirname as argument
     BRTmuxSend "cd '" . expand('%:p:h') . "'"
endfunction

function! python#PythonRunI()
    " TODO take fname as argument
    " Run python script interactively
    BRTmuxSend "python -i '" . expand('%') . "'"
endfunction

function! python#PythonDbstop()
    " TODO take line number as argument
    " Set a debugging breakpoint for use with pdb
    let l:pdb = g:breptile_python_interp == 2 ? 'ipdb' : 'pdb'
    execute 'normal! Oimport ' . l:pdb . '; ' . l:pdb . ".set_trace()j"
endfunction

function! python#PythonDebug(bang) abort
    if g:breptile_python_interp == 2
        let &efm =  '%C %.%#,'
        let &efm .= '%C-%.%#> %l %.%#,'
        let &efm .= '%E%f in %m,'
        let &efm .= '%Z%\(%[%^ :]: %\)%\@=%m,'
        let &efm .= '%-G%\s%#'
    else
        " Non-ipython message, see ":h errorformat-multi-line"
        let &efm =  '%C    %.%#,'
        let &efm .= '%E  File "%f"\, line %l\, %m,'
        let &efm .= '%Z%\(%[%^ :]: %\)%\@=%m'
    endif

    " TODO add to configuration options + documentation
    if g:breptile_python_interp > 0
        let b:endpat = '>>>'        " assuming ipython prompt contains >>>
    else
        let b:endpat = '\[.*\]\$'   " bash prompt... user will have to set
    endif

    cexpr [] " clear the qflist
    let l:cmd = 'ptb ' . b:breptile_tmuxpane . ' ' . shellescape(b:endpat)
    if a:bang
        " If [!] given, fill qflist, but do not jump to first error
        cgetexpr system(l:cmd)
    else
        " create qflist and jump to first error
        cexpr system(l:cmd)
    endif
endfunction

function! python#UseShell() abort
    let g:breptile_python_interp = 0
    call python#PythonConfig()
    BRGetConfig
endfunction

"----------------------------------------------------------------------------- 
"       Private API 
"-----------------------------------------------------------------------------
function! s:PyHelp(type) abort
    let l:string = breptile#GetOp(a:type)
    execute "BRTmuxSend '" . l:string . "?'"
endfunction

" Send text operator
noremap <silent> <Plug>PyHelpNorm :set operatorfunc=<SID>PyHelp<CR>g@
noremap <silent> <Plug>PyHelpVis  :<C-u>call <SID>PyHelp(visualmode())<CR>

let g:loaded_breptile_python_util = 1
" vim:fdm=syntax

"=============================================================================
"     File: breptile.vim
"  Created: 09/15/2016, 19:26
"   Author: Bernie Roesler
"
"  Description: Functions for running commands/scripts in any tmux pane
"
"=============================================================================
" if exists("g:loaded_breptile") || &cp || (strlen($TMUX) == 0)
"   finish
" endif

"-----------------------------------------------------------------------------
"       Configuration 
"-----------------------------------------------------------------------------
if !exists("g:breptile_mapkeys")
    let g:breptile_mapkeys = 0
endif

if !exists("g:breptile_usetpgrep")
    let g:breptile_usetpgrep = 0
endif


"-----------------------------------------------------------------------------
"       Functions
"-----------------------------------------------------------------------------
function! s:TmuxSend(pane, text) abort "{{{
    " Send command and carriage return
    call system('tmux send-keys -t ''' . a:pane . ''' -l ' . shellescape(a:text) .
           \ '&& tmux send-keys -t ''' . a:pane . ''' C-m')
endfunction
"}}}
function! s:GetConfig() abort "{{{
    if exists("b:breptile_tmuxpane") && (strlen(b:breptile_tmuxpane) > 0)
        return 1
    else
        let b:breptile_tmuxpane = ''
    endif

    " If we don't have a pane to use, find one. Prioritize tpgrep over global
    " default set by user
    if g:breptile_usetpgrep && exists("b:tpgrep_pat")
        call s:FindProgramPane(b:tpgrep_pat)
    elseif exists("g:breptile_defaultpane")
        echom "Setting b:breptile_tmuxpane to g:breptile_defaultpane..."
        let b:breptile_tmuxpane = g:breptile_defaultpane
    endif

    " at this point, b:breptile_tmuxpane should exist, but may be empty
    if strlen(b:breptile_tmuxpane) == 0
        echohl WarningMsg 
              \| echom "WARNING: Program is not running!"
              \| echohl None
        return 0
    else
        return 1
    endif
endfunction
"}}}
function! s:FindProgramPane(tpgrep_pat) abort "{{{
    if strlen(a:tpgrep_pat) == 0
        echohl WarningMsg 
              \| echom "WARNING: b:tpgrep_pat is empty!"
              \| echohl None
        return
    endif

    " TODO add option to search within session (make that default?)
    let l:tmux_window = system("tmux display-message -p ''#{window_id}''")[:-2]

    " Include pattern to match time, so user only has to grep for program name
    let l:pat = "'[0-9]:[0-9]{2}.[0-9]{2} " . a:tpgrep_pat . "'"
    let l:syscom = 'tpgrep -t ' . l:tmux_window . ' ' . l:pat
    let b:breptile_tmuxpane = system(l:syscom)[:-2]

    " Error checking
    if b:breptile_tmuxpane[:4] ==# "Usage"
        echoe "tpgrep error!"
    endif
endfunction
"}}}
function! s:UpdateProgramPane(...) abort "{{{
    if a:0 == 0
        call s:FindProgramPane(b:tpgrep_pat)
    else
        call s:FindProgramPane(a:1)
    endif
endfunction
" }}}
function! s:EscapeText(text) abort "{{{
    let l:text = a:text
    let l:text = substitute(l:text, ';', '; ', 'g')
    let l:text = substitute(l:text, '%', '\%', 'g')
    " TODO Figure out how to deal with extra newline characters in 
    " Visual selection!!
    let l:text = substitute(l:text, "\n", "\<CR>", 'g')

    return l:text
endfunction
"}}}
function! s:SendOp(type) abort "{{{
    if !s:GetConfig()
        return
    endif
    let save_reg = @@

    " copy motion for type
    if a:type ==# 'v'
        silent execute "normal! `<v`>y"
    elseif a:type ==# 'V'
        silent execute "normal! '<V'>y"
        let @@ = @@[:-2]    " remove repeated newline
    elseif a:type ==# 'char'
        silent execute "normal! `[v`]y"
    else
        " ignore block-visual '' 
        return
    endif

    call s:TmuxSend(b:breptile_tmuxpane, s:EscapeText(@@))

    let @@ = save_reg
endfunction

" Create <Plug> for user mappings
noremap <silent> <Plug>BReptileSendOpNorm :set operatorfunc=<SID>SendOp<CR>g@
noremap <silent> <Plug>BReptileSendOpVis  :<C-u>call <SID>SendOp(visualmode())<CR>

"}}}
function! s:SendRange() range abort "{{{
    if !s:GetConfig()
        return
    endif
    let save_reg = @@
    silent execute a:firstline . ',' . a:lastline . 'y'
    call s:TmuxSend(b:breptile_tmuxpane, s:EscapeText(@@))
    let @@ = save_reg
endfunction

" }}}
function! s:SendCount(count) abort "{{{
    if !s:GetConfig()
        return
    endif
    let save_reg = @@
    silent execute 'normal! ' . a:count . 'yy'
    call s:TmuxSend(b:breptile_tmuxpane, s:EscapeText(@@))
    let @@ = save_reg
endfunction

" }}}

"-----------------------------------------------------------------------------
"       Commands and Key maps {{{
"-----------------------------------------------------------------------------
" Allow user to manually search for pane
command! -nargs=?    BReptileFindPane   call s:UpdateProgramPane(<f-args>)
command! -count      BReptileSendCount  call s:SendCount(<count>)
command! -range -bar BReptileSendRange  <line1>,<line2>call s:SendRange()

" User uses these maps in their vimrc:
if g:breptile_mapkeys
    " ALLOW recursion here so that <Plug>s work properly
    nmap <silent> <Leader>e <Plug>BReptileSendOpNorm
    vmap <silent> <Leader>e <Plug>BReptileSendOpVis
endif
"}}}

let g:loaded_gnuplotvim = 1
"=============================================================================
"=============================================================================

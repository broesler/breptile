"=============================================================================
"     File: breptile.vim
"  Created: 09/15/2016, 19:26
"   Author: Bernie Roesler
"
"  Description: Functions for running commands/scripts in any tmux pane
"
"=============================================================================
" if exists("g:loaded_breptile") || &cp
"   finish
" endif

if !exists("g:breptile_mapkeys")
    let g:breptile_mapkeys = 1
endif

"-----------------------------------------------------------------------------
"       Tmux  
"-----------------------------------------------------------------------------
" s:TmuxSend {{{
function! s:TmuxSend(pane, text)
    " Send command and carriage return
    call system('tmux send-keys -t ''' . a:pane . ''' -l ' . shellescape(a:text) .
           \ '&& tmux send-keys -t ''' . a:pane . ''' C-m')

endfunction
"}}}

"-----------------------------------------------------------------------------
"       Functions
"-----------------------------------------------------------------------------
" s:GetConfig {{{
function! s:GetConfig()
    if exists("b:breptile_tmuxpane") && !b:breptile_tmuxpane
        return
    endif

    if exists("b:tpgrep_pat") && !b:tpgrep_pat
        " Find appropriate program's pane
        call s:FindProgramPane(b:tpgrep_pat)
    else
        echohl WarningMsg 
              \| echom "WARNING: Program is not running!\n"
              \ . "Please choose b:breptile_tmuxpane or set b:tpgrep_pat."
              \| echohl None
    endif
endfunction
"}}}
" s:FindProgramPane {{{
function! s:FindProgramPane(tpgrep_pat)
    " Check if we are running tmux
    if strlen($TMUX) > 0 
        " system() returns a list, so strip the trailing newline (only take up to
        " the 2nd to last character)
        let l:tmux_window = system("tmux display-message -p ''#{window_id}''")[:-2]

        " Add pattern to match time, so user only has to grep for program name
        let l:pat = "'[0-9]:[0-9]{2}.[0-9]{2} " . a:tpgrep_pat . "'"
        let l:syscom = 'tpgrep -t ' . l:tmux_window . ' ' . l:pat
        let b:breptile_tmuxpane = system(l:syscom)[:-2]

        " Error checking
        if b:breptile_tmuxpane[:4] ==# "Usage"
            let b:breptile_tmuxpane = ''
            echoe "tpgrep error!"
        endif
    else 
        let b:breptile_tmuxpane  = '' 
    endif
endfunction
"}}}
" s:EscapeText {{{
function! s:EscapeText(text)
    let l:text = a:text
    let l:text = substitute(l:text, ';', '; ', 'g')
    let l:text = substitute(l:text, '%', '\%', 'g')
    " TODO Figure out how to deal with extra newline characters in 
    " Visual selection!!
    let l:text = substitute(l:text, "\n", "\<CR>", 'g')

    return l:text
endfunction
"}}}
" s:SendOp function {{{
function! s:SendOp(type)
    call s:GetConfig()
    let save_reg = @@

    " copy motion for type
    if a:type ==# 'v'
        silent execute "normal! `<v`>y"
    elseif a:type ==# 'V'
        silent execute "normal! '<V'>y"
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
noremap <script> <silent> <Plug>BReptileSendOpNorm :set operatorfunc=<SID>SendOp<CR>g@
noremap <script> <silent> <Plug>BReptileSendOpVis  :<C-u>call <SID>SendOp(visualmode())<CR>

"}}}
" s:SendRange function {{{
function! s:SendRange() range
    call s:GetConfig()
    let save_reg = @@
    silent execute a:firstline . ',' . a:lastline . 'y'
    call s:TmuxSend(b:breptile_tmuxpane, s:EscapeText(@@))
    let @@ = save_reg
endfunction

command! -range -bar BReptileSendRange <line1>,<line2>call s:SendRange()
" }}}
" s:SendCount {{{
function! s:SendCount(count)
    call s:GetConfig()
    let save_reg = @@
    silent execute 'normal! ' . a:count . 'yy'
    call s:TmuxSend(b:breptile_tmuxpane, s:EscapeText(@@))
    let @@ = save_reg
endfunction

command! -count BReptileSendCount call s:SendCount(<count>)
" }}}

"-----------------------------------------------------------------------------
"       Map keys 
"-----------------------------------------------------------------------------
" User uses these maps in their vimrc:
if g:breptile_mapkeys
    " ALLOW recursion here so that <Plug>s work properly
    nmap <silent> <Leader>e <Plug>BReptileSendOpNorm
    vmap <silent> <Leader>e <Plug>BReptileSendOpVis
endif

let g:loaded_gnuplotvim = 1
"=============================================================================
"=============================================================================

"=============================================================================
"     File: breptile.vim
"  Created: 09/15/2016, 19:26
"   Author: Bernie Roesler
"
"  Description: Functions for running commands/scripts in any tmux pane
"
"=============================================================================
" if exists('g:loaded_breptile') || &cp
"   finish
" endif

"-----------------------------------------------------------------------------
"       Tmux  
"-----------------------------------------------------------------------------
" TmuxSend commands {{{
function! s:TmuxSend(pane, text)
    " Send command and carriage return
    call system('tmux send-keys -t ''' . a:pane . ''' -l ' . shellescape(a:text) .
           \ '&& tmux send-keys -t ''' . a:pane . ''' C-m')

endfunction
"}}}

"-----------------------------------------------------------------------------
"       Utilities 
"-----------------------------------------------------------------------------
" s:GetConfig {{{
function! s:GetConfig()
    if exists("b:breptile_tmuxpane") && !b:breptile_tmuxpane
        return
    endif

    " Find appropriate program's pane
    call s:FindProgramPane(b:tpgrep_pat)

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
" EscapeText {{{
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
    let save_reg = @@

    call s:GetConfig()

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

    " Send string to tmux 
    call s:TmuxSend(b:breptile_tmuxpane, s:EscapeText(@@))

    let @@ = save_reg
endfunction

" Create <Plug> for user mappings
noremap <SID>SendOpNorm :set operatorfunc=<SID>SendOp<CR>g@
noremap <SID>SendOpVis  :<C-u>call <SID>SendOp(visualmode())<CR>

noremap <script> <silent> <Plug>BReptileSendOpNorm <SID>SendOpNorm
noremap <script> <silent> <Plug>BReptileSendOpVis  <SID>SendOpVis

nmap <silent> <Leader>e <Plug>BReptileSendOpNorm
vmap <silent> <Leader>e <Plug>BReptileSendOpVis

" nnoremap <silent> <Leader>e :set operatorfunc=<SID>SendOp<CR>g@
" vnoremap <silent> <Leader>e :<C-u>call <SID>SendOp(visualmode())<CR>
"}}}
" s:SendRange function {{{
function! s:SendRange() range
    let save_reg = @@

    call s:GetConfig()

    " Copy the text
    silent execute a:firstline . ',' . a:lastline . 'y'

    " Send string to tmux 
    call s:TmuxSend(b:breptile_tmuxpane, s:EscapeText(@@))

    let @@ = save_reg
endfunction

" User command
command -range -bar -nargs=0 BReptileSendRange <line1>,<line2>call s:SendRange()
" }}}


let g:loaded_gnuplotvim = 1
"=============================================================================
"=============================================================================

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
"       Configuration 
"-----------------------------------------------------------------------------
if !exists("g:buf_file")
    let g:buf_file = '/tmp/breptile_paste.txt'
endif

"-----------------------------------------------------------------------------
"       Tmux  
"-----------------------------------------------------------------------------
" TmuxSend commands {{{
function! TmuxSend(text, pane)
    " " Append a carriage return so command gets entered in other pane
    if a:text[-1] !~ '\(\r\|\n\)' 
        let l:text = a:text . "\n"
    else
        let l:text = a:text
    endif

    echom 'a:text[-1] = ' . a:text[-1]
    echom l:text

    call s:WriteBufFile(l:text)

    let l:syscom = "tmux load-buffer " . shellescape(g:buf_file) 
    call system(l:syscom)

    let l:syscom = "tmux paste-buffer -d -t " . shellescape(a:pane) 
    call system(l:syscom)

    call system("rm -f " . shellescape(g:buf_file))
endfunction
"}}}

"-----------------------------------------------------------------------------
"       Utilities 
"-----------------------------------------------------------------------------
" WritePasteFile of commands {{{
function! s:WriteBufFile(text)
    call system("cat > " . g:buf_file, a:text)
endfunction
"}}}
" BreptileGetConfig {{{
function! s:BReptileGetConfig()
    if exists("b:breptile_tmuxpane") || !b:breptile_tmuxpane
        return
    endif

    " Find appropriate program's pane
    call s:FindProgramPane(b:tpgrep_pat)

    if exists("g:breptile_default_tmuxpane") && !b:breptile_tmuxpane
        let b:breptile_tmuxpane = g:breptile_default_tmuxpane
        return
    endif
endfunction
"}}}
" FindProgramPane of command {{{
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
" s:BReptileOperator function {{{
function! s:BReptileOperator(type)
    let save_reg = @@

    call s:BReptileGetConfig()

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

    let mcom = @@

    " NOTE: For some reason, an extra carriage return gets transmitted when
    " running a single line vs. multiple line selection
    " if a:type ==# 'V'
    "     let mcom = mcom[:-2]
    " endif

    let mcom = substitute(mcom, ';', '; ', 'g')
    let mcom = substitute(mcom, '%', '\%', 'g')
    let mcom = substitute(mcom, '#', '\#', 'g')
    " TODO Figure out how to deal with newline characters in Visual selection!!
    let mcom = substitute(mcom, "\n", "\<CR>", 'g')

    " Call shellescape() for proper treatment of string characters
    echom mcom
    " call system('ts -t ''' . b:breptile_tmuxpane . ''' ' . shellescape(mcom))
    call system('tmux send-keys -t ''' . b:breptile_tmuxpane . ''' ' . shellescape(mcom))
    call system('tmux send-keys -t ''' . b:breptile_tmuxpane . ''' C-m')

    " Send literal string to tmux
    " call TmuxSend(mcom, b:breptile_tmuxpane)

    let @@ = save_reg
endfunction
"}}}

nnoremap <silent> <Leader>e :set operatorfunc=<SID>BReptileOperator<CR>g@
vnoremap <silent> <Leader>e :<C-u>call <SID>BReptileOperator(visualmode())<CR>

let g:loaded_gnuplotvim = 1
"=============================================================================
"=============================================================================

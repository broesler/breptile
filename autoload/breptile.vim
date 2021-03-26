"=============================================================================
"     File: breptile/autoload/breptile.vim
"  Created: 10/07/2016, 12:29
"   Author: Bernie Roesler
"
"  Description: General autoload functions for breptile plugin
"
"=============================================================================

"-----------------------------------------------------------------------------
"       Public API 
"-----------------------------------------------------------------------------
function! breptile#GetConfig(bang, ...) abort 
    if !a:bang 
       \ && exists("b:breptile_tmuxpane") 
       \ && (strlen(b:breptile_tmuxpane) > 0)
        echom "Program pane '" . b:breptile_tmuxpane
            \ . "' already set for program '" . &filetype . "'"
        return 0    " no updates to be made, carry on
    endif

    let b:breptile_tmuxpane = ''

    if a:0 
        let l:pat = a:1
    elseif exists(b:breptile_tpgrep_pat) || (strlen(b:breptile_tpgrep_pat) > 0)
        let l:pat = b:breptile_tpgrep_pat
    else
        call s:Warn("WARNING: b:breptile_tpgrep_pat is empty!")
        return 1
    endif

    " If we don't have a pane to use, find one.
    if g:breptile_usetpgrep || a:bang
        call s:FindProgramPane(l:pat)
    endif

    if strlen(b:breptile_tmuxpane) > 0  " We have a pane!
        echom "Found program '" . &filetype 
            \ . "' running in pane " . b:breptile_tmuxpane
        return 0
    else
        call s:Warn("breptile#GetConfig() failed to find a pane!")
        return 2    
    endif
endfunction

function! breptile#SendRange() range abort 
    if !s:IsValidPane()
        return
    endif
    let l:reg_save = @@
    silent execute a:firstline . ',' . a:lastline . 'y'
    call breptile#TmuxSendwithReturn(b:breptile_tmuxpane, s:EscapeText(@@))
    let @@ = l:reg_save
endfunction

function! breptile#SendCount(count) abort 
    if !s:IsValidPane()
        return
    endif
    let l:reg_save = @@
    silent execute 'normal! ' . a:count . 'yy'
    call breptile#TmuxSendwithReturn(b:breptile_tmuxpane, s:EscapeText(@@))
    let @@ = l:reg_save
endfunction

function! breptile#RunScript(...) abort 
    if !s:IsValidPane()
        return
    endif
    " If we have an argument, use it as the filename to be run
    let l:filename = a:0 ? a:1 : expand("%:p")
    " Use the calling program's command
    let l:com = printf(b:breptile_runfmt, l:filename)
    call breptile#TmuxSendwithReturn(b:breptile_tmuxpane, l:com)
endfunction

function! breptile#TmuxSend(pane, text) abort 
    if !s:IsValidPane()
        return
    endif
    " Send command NOT literally, do not send carriage return
    let l:com = "tmux send-keys -t '" . a:pane . "' " . shellescape(a:text)
    call system(l:com)
endfunction

function! breptile#TmuxSendwithReturn(pane, text) abort 
    if !s:IsValidPane(a:pane)
        call s:Warn("WARNING: pane '" . a:pane . "' is invalid!")
        return
    endif
    " Send command literally, and then send carriage return keystroke
    let l:litkeys = "tmux send-keys -t '" . a:pane . "' -l " . shellescape(a:text)
    let l:creturn = "tmux send-keys -t '" . a:pane . "' C-m"
    call system(l:litkeys . ' && ' . l:creturn)
endfunction

function! breptile#GetOp(type) abort
    try
        " Get string from g@ operator
        " Selection needs to include start and end points 
        let l:sel_save = &selection
        let &selection = "inclusive"
        " function will wipe out unnamed register, so save its contents
        let l:reg_save = @@

        " copy motion for type (see :help g@)
        if (a:type ==# 'v') || (a:type ==# 'V')
            silent execute "normal! gvy"
        elseif a:type ==# 'char'
            silent execute "normal! `[v`]y"
        elseif a:type ==# 'line'
            silent execute "normal! '[V']y"
        else
            " ignore block-visual '<C-v>' 
            return  
        endif

        return @@
    finally
        " Return selection and unnamed register to previous values
        let &selection = l:sel_save
        let @@ = l:reg_save
    endtry
endfunction

"-----------------------------------------------------------------------------
"       Private API 
"-----------------------------------------------------------------------------
function! s:FindProgramPane(tpgrep_pat) abort 
    if strlen(a:tpgrep_pat) == 0
        call s:Warn("WARNING: b:breptile_tpgrep_pat is empty!")
        return
    endif

    " TODO search with other tmux servers (tmux -L ...), or (tmux -L default)
    " [:-2] strips newline returned by 'system'
    " Get current window ID:
    let l:tmux_window = system("tmux display-message -p ''#{window_id}''")[:-2]

    " Search within session (remove -s to search within window )
    let l:pat = a:tpgrep_pat
    let l:syscom = 'tpgrep -s -t ' . l:tmux_window . ' ' . l:pat
    let b:breptile_tmuxpane = system(l:syscom)[:-2]

    " Error checking
    if v:shell_error
        echoe "tpgrep error!"
    endif

    " Make sure we didn't find vim's pane
    " TODO this line will break if using manual 'bottom-left', etc. Perhaps
    " come up with a way to normalize pane references??
    if b:breptile_tmuxpane ==# g:breptile_vimpane
        let b:breptile_tmuxpane = ''
    endif
endfunction

function! s:EscapeText(text) abort 
    let l:text = a:text
    " may only need for matlab:
    let l:text = substitute(l:text, ';', '; ', 'g') 
    " Escape '%' so vim doesn't insert filename
    let l:text = substitute(l:text, '%', '\%', 'g')
    let l:text = substitute(l:text, "\n", "\<CR>", 'g')

    return l:text
endfunction

function! s:SendOp(type) abort 
    if !s:IsValidPane()
        return
    endif
    let l:string = breptile#GetOp(a:type)
    call breptile#TmuxSendwithReturn(b:breptile_tmuxpane, s:EscapeText(l:string))
endfunction

function! s:IsValidPane(...) 
    if a:0
        let l:pane = a:1
    else
        if exists("b:breptile_tmuxpane")
            let l:pane = b:breptile_tmuxpane
        else
            let l:pane = ''
        endif
    endif
    let l:test = ((strlen(l:pane) > 0) && (l:pane !=# g:breptile_vimpane))
    " TODO test is pane exists in tmux?
    if !l:test
        call s:Warn("WARNING: Pane not set for '" . &filetype . "'. Run BRGetConfig.")
    endif
    return l:test
endfunction

function! s:Warn(str) abort 
    echohl WarningMsg | echom a:str | echohl None
    return
endfunction

"-----------------------------------------------------------------------------
"        Create <Plug> for user mappings
"-----------------------------------------------------------------------------
" Send text operator
noremap <silent> <Plug>BRSendOpNorm :set operatorfunc=<SID>SendOp<CR>g@
noremap <silent> <Plug>BRSendOpVis  :<C-u>call <SID>SendOp(visualmode())<CR>

"=============================================================================
"=============================================================================

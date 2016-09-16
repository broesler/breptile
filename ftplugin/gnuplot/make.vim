"=============================================================================
"     File: make.vim
"  Created: 09/12/2016, 22:26
"   Author: Bernie Roesler
"
"  Description: Functions for running gnuplot scripts in the CLI
"
"=============================================================================
" if exists('g:loaded_gnuplotvim') || &cp
"   finish
" endif

if !exists("g:gnuplot_defaultoptions")
    let g:gnuplot_defaultoptions = " -p"
endif

if !exists("g:gnuplot_command")
    if executable('gnuplot')
        let g:gnuplot_command = "gnuplot"
    else
        finish
    endif
    let g:gnuplot_command .= g:gnuplot_defaultoptions
endif

if !exists("g:gnuplot_runopt")
    let g:gnuplot_runopt = 0    " run in current (vim) pane
endif

if !exists("g:gnuplot_geterrors")
    let g:gnuplot_geterrors = 0
endif

if exists("g:gnuplot_pane")
    let b:breptile_tmuxpane = g:gnuplot_pane
endif

function! GnuplotRunFile()
    silent !clear
    " Error looks like:
    "   set itle 'Simple Plots'
    "       ^
    "   "simple_1_gnuplot.gpi", line 7: unrecognized option - see 'help set'.
    let b:errorformat="%E%p^,%Z\"%f\"\\, line %l:%m"
    let b:makeprg = g:gnuplot_command . " " . bufname("%")

    write | silent make | redraw!
endfunction
nnoremap <buffer> <localleader>M :call GnuplotRunFile()<CR>

" Macros for running gnuplot in tmux {{{
" TODO give 'pat' as argument
function! FindGnuplotPane()
    " if we are running tmux...
    if strlen($TMUX) > 0 
        " system() returns a list, so strip the trailing newline (only take up to
        " the 2nd to last character)
        let g:tmux_window = system("tmux display-message -p ''#{window_id}''")[:-2]

        " Only search for Gnuplot in this session
        " TODO add variable to determine whether to send commands to another,
        " already-running Gnuplot session or not (i.e. g:send_tmux_cmds=0 or 1)
        let l:pat = "'[0-9]:[0-9]{2}.[0-9]{2} gnuplot'"
        let l:sys_com = system('tpgrep -t ' . g:tmux_window . " " . l:pat)
        let g:gnuplot_pane = substitute(l:sys_com, "\n",'','g') 

        " Error checking
        if g:gnuplot_pane[:4] ==# "Usage"
            let g:gnuplot_pane = ''
            echoe "Gnuplot not found!"
        endif
    else 
        let g:gnuplot_pane = '' 
    endif
endfunction
command! FindGnuplotPane :call FindGnuplotPane()

"}}}--------------------------------------------------------------------------
" "       RunGnuplotScript in interactive window {{{
" "-----------------------------------------------------------------------------
" function! RunGnuplotScript()
"     let &l:makeprg="ts -t left \"load ".shellescape(expand("%"))."\""
"     " save changes made to the file so Matlab gets the most recent version
"     update | silent! make! | redraw!
" endfunction
" command! RunGnuplotScript :call RunGnuplotScript()
"
" "}}}--------------------------------------------------------------------------
" "       Evaluate current selection {{{
" "-----------------------------------------------------------------------------
" function! EvaluateSelection(code)
"     " " let mcom = s:GetVisualSelection()
"     " let mcom = GetVisualSelection()
"     " " Only need to escape ; if there is no space after it (not sure why?)
"     " let mcom = substitute(mcom, ';', '; ', 'g')
"     " " Need to escape `%' so vim doesn't insert filename
"     " let mcom = substitute(mcom, '%', '\%', 'g')
"     " " Change newlines to literal carriage return so shellescape() does not
"     " " escape them (sends literal \ to tmux send-keys)
"     " let mcom = substitute(mcom, "\n", '\\\\\', 'g')
"     " " Call shellescape() for proper treatment of string characters
"     " " call system('ts -t '''.g:tmux_pane.''' '.shellescape(mcom))
"     " call system('ts -t left '.shellescape(mcom))
"
"     " substitute single quotes for 
"     let mcom = substitute(a:code,"'","'\\\\''",'g')
"     let mcom = substitute(mcom, "\n", '\\\\\', 'g')
"     " call system("ts -t left '".shellescape(mcom)."'")
"     call system("ts -t left '".shellescape(mcom)."'")
" endfunction
" command! -nargs=1 EvaluateSelection :call EvaluateSelection(<args>)
" " command! -range EvaluateSelection :call s:EvaluateSelection()
"
" "}}}--------------------------------------------------------------------------
" "       Keymaps
" "-----------------------------------------------------------------------------
" " nnoremap <Leader>M   :update<bar>silent! make!<bar>redraw!<CR>
" nnoremap <Leader>M   :RunGnuplotScript<CR>
"
" " Evaluate Current selection
" " vnoremap <Leader>e :EvaluateSelection<CR>
" " vnoremap <Leader>e "ry :call EvaluateSelection(@r)<CR>
" vnoremap <Leader>e "ry :EvaluateSelection @r <CR>

let g:loaded_gnuplotvim = 1
"=============================================================================
"=============================================================================

"=============================================================================
"     File: make.vim
"  Created: 09/12/2016, 22:26
"   Author: Bernie Roesler
"
"  Description: Functions for running gnuplot scripts in the CLI
"
"=============================================================================
if !exists("g:gnuplot_command")
  let g:gnuplot_command = "gnuplot -p"
endif

function! GnuplotRunFile()
  silent !clear
  " Error looks like:
  "   set itle 'Simple Plots'
  "       ^
  "   "simple_1_gnuplot.gpi", line 7: unrecognized option - see 'help set'.
  " setl errorformat=%Z\"%f\"\,\ line\ %l:\ %m,%E%s,%C%p^
  let &l:errorformat="%E%p^,%Z\"%f\"\\, line %l:%m"

  let &l:makeprg = g:gnuplot_command . " " . bufname("%")

  write | silent make | redraw!
endfunction

nnoremap <buffer> <localleader>M :call GnuplotRunFile()<CR>

" "}}}--------------------------------------------------------------------------
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
"=============================================================================
"=============================================================================

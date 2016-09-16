"=============================================================================
"     File: ~/src/matlabvim/matlab.vim
"   Author: Bernie Roesler
"  Created: 12/07/15, 12:27
"
" Last Modified: 05/16/2016, 10:10
"
"  Description: MATLAB filetype settings and mappings
"=============================================================================
"       Macros for running MATLAB in tmux {{{
"-----------------------------------------------------------------------------
if !exists("g:matlab_pane")
  let g:matlab_pane = ''
endif

augroup update
    au!
    " Save global variable of which pane matlab is running in
    au BufEnter,BufWritePost *.m FindMatlabPane
augroup END

function! FindMatlabPane()
    " if we are running tmux...
    if strlen($TMUX) > 0 
        " system() returns a list, so strip the trailing newline (only take up to
        " the 2nd to last character)
        let l:tmux_window = system("tmux display-message -p ''#{window_id}''")[:-2]

        " Only search for Matlab in this session
        " TODO add variable to determine whether to send commands to another,
        " already-running Matlab session or not (i.e. g:send_tmux_cmds=0 or 1)
        let l:pat = "'[0-9]:[0-9]{2}.[0-9]{2} [r]lwrap.*matlab'" 
        let l:sys_com = system('tpgrep -t ' . l:tmux_window . " " . l:pat)
        let g:matlab_pane = substitute(l:sys_com, "\n",'','g') 
    else 
        let g:matlab_pane = '' 
    endif
endfunction
command! FindMatlabPane :call FindMatlabPane()

"}}}--------------------------------------------------------------------------
"       Lint and Run in one step {{{
"-----------------------------------------------------------------------------
" function! LintAndRunMatlabScript()
"     let qflist = []       " start with empty error list
"
"     " Set errorformat for both lint and Matlab output
"     " NOTE: each entry must end in a comma for concatenation
"     let b:efm="%EL %l (C %c%.%#): Parse error%.%#: %m,"
"                 \."%EL %l (C %c%.%#): Invalid syntax at '%s'%.%#. %m,"
"                 \."%WL %l (C %c%.%#): %m,"
"                 \."%WWarning: %m,%Z> in %f (line %l),"
"                 \."%ZError in %f (line %l),%+EIndex exceeds%.%#,%C%m,%-G%.%#,"
"                 \."%ZError in %f (line %l),%+EError using%.%#,%C%m,%-G%.%#,"
"                 \."%EError: File: %f Line: %l Column: %c,%Z%m"
"
"     " LINT: needs full filename
"     let b:makeprg="/Applications/MATLAB_R2015b.app/bin/maci64/mlint "
"                 \.shellescape(expand("%:p"))
"                 " \.a:filename.".m"
"                 " \.shellescape(expand(a:filename))
"
"     " save changes made to the file so Matlab gets the most recent version
"     update | silent! make! | redraw!
"
"     " Add to qflist
"     let qflist += getqflist()
"
"     " Check for lint errors (ignore warnings)
"     let ecount = 0
"     for i in qflist
"         let type = get(i, 'type')
"         if type == "E"
"             let ecount = 1
"             break
"         endif
"     endfor
"
"     " If there are no 'errors' in qflist, run script
"     if ecount == 0
"         " RUN:
"         " Choose [r]un [m]atlab [t]mux with current file (no extension)
"         " Use '-p' flag to echo Matlab output to vim's pane to parse for errors
"         let b:makeprg="rmt -p ".shellescape(expand("%:t:r"))
"         " let b:makeprg="rmt -p ".shellescape(expand(a:filename))
"         silent! make! | redraw!
"         let qflist += getqflist()
"     endif
"
"     " Open quickfix window if necessary
"     if !empty(qflist)
"         call setqflist(qflist,'r')
"         botright copen
"     else
"         cclose
"     endif
"
" endfunction
" command! LintAndRunMatlabScript :call LintAndRunMatlabScript()
" command! -nargs=1 LintAndRunMatlabScript :call LintAndRunMatlabScript(shellescape(expand(<f-args>)))

"}}}--------------------------------------------------------------------------
"       Lint current file {{{
"-----------------------------------------------------------------------------
function! LintMatlabScript()
    " TODO make full Matlab path a script variable
    " Use the built-in Matlab lint function
    " let b:makeprg="/Applications/MATLAB_R2015b.app/bin/maci64/mlint "
    "             \.shellescape(expand("%:p"))

    " Give <filename.m> <filename> to make mlint print filenames
    " mlint doesn't provide filename information except if multiple
    " filenames are given 
    " With the following command :
    " mlint <filename> <filename without extension>
    " mlint produces an output like that :
    " ========== <filename> ==========
    " L x (C y): ID : Message
    " L x (C y): ID : Message
    " ..
    " ..
    " ========== <filename without extension> ==========
    " L 0 (C 0): MDOTM :Filename 'filename' must end in .m or .M

    let b:makeprg="/Applications/MATLAB_R2015b.app/bin/maci64/mlint -id "
                \.shellescape(expand("%:p")).' '.shellescape(expand("%:p:r"))

    " List efm most restrictive to least restrictive patterns
    " let b:efm="%EL %l (C %c%.%#): Parse error%.%#: %m,"
    "             \."%EL %l (C %c%.%#): Invalid syntax at '%s'%.%#. %m,"
    "             \."%WL %l (C %c%.%#): %m"
    let b:efm= "%P==========\ %f\ ==========,"
          \."%-G%>==========\ %s\ ==========,"
          \."%-G%>L\ %l\ (C\ %c):\ MDOTM%m,"
          \."L\ %l\ (C\ %c):\ %m,"
          \."L\ %l\ (C\ %c-%*[0-9]):\ %m,"
          \."%-Q"

    " save changes made to the file so Matlab gets the most recent version
    update | silent! make! | redraw!
endfunction
command! LintMatlabScript :call LintMatlabScript()

"}}}--------------------------------------------------------------------------
"       Run current file {{{
"-----------------------------------------------------------------------------
function! RunMatlabScript()
    " Choose [r]un [m]atlab [t]mux with current file (no extension)
    " Use '-p' flag to echo Matlab output to vim's pane to parse for errors
    " let b:makeprg="rmt -p ".shellescape(expand("%:t:r"))

    " Check if Matlab is running!
    if strlen(g:matlab_pane) == 0
        echohl WarningMsg 
              \| echom 'WARNING: Matlab is not running!' 
              \| echohl None
        return -1
    end
    
    " Need to figure out how to escape g:matlab_pane so that makeprg sends the
    " literal string to the command-line!!
    let mpane = substitute(g:matlab_pane, '%','\\%', 'g')
    let b:makeprg='ts -t '''.mpane.''' '.shellescape(expand("%:t:r"))

    " NOTE: efm will not do anything with makeprg set to "ts -t..." because
    " just sending keys to tmux will not report anything back to the vim pane
    "
    " List efm most restrictive to least restrictive patterns
    let b:efm="%WWarning: %m,%Z> in %f (line %l),"
                \."%ZError in %f (line %l),%+EError using%.%#,%C%m,%-G%.%#"
    " \."%EError: File: %f Line: %l Column: %c,%Z%m"

    " save changes made to the file so Matlab gets the most recent version
    update | silent! make! | redraw!
endfunction
command! RunMatlabScript :call RunMatlabScript()

"}}}--------------------------------------------------------------------------
"       Declare signs to mark debugging stops, and cursor {{{
"-----------------------------------------------------------------------------
hi clear SignColumn
hi default DebugStopHL ctermfg=red
hi link DebugCursorHL Search
sign define dbstop text=$$ texthl=DebugStopHL
sign define piet   text=>> texthl=DebugCursorHL

"}}}--------------------------------------------------------------------------
"       Debugging stop {{{
"-----------------------------------------------------------------------------
function! Dbstop()
    write %
    let lnr = line('.')
    let mcom = "dbstop in ".expand("%")." at ".lnr
    call system('ts -t '''.g:matlab_pane.''' '.mcom)
    " place sign at dbstop current line, use lnr as ID
    exe ":silent sign place ".lnr." line=".lnr." name=dbstop file=".expand("%:p")
    " keep file from being modified during debugging
    set noma
endfunction
command! Dbstop :call Dbstop()

"}}}--------------------------------------------------------------------------
"       Clear debugging stop on specific line {{{
"-----------------------------------------------------------------------------
function! Dbclear()
    let mcom = "dbclear in " . expand("%") . " at " . line(".")
    call system('ts -t '''.g:matlab_pane.''' '.mcom)
    silent! sign unplace
endfunction
command! Dbclear :call Dbclear()

"}}}--------------------------------------------------------------------------
"       Clear all debugging stops in all files {{{
"-----------------------------------------------------------------------------
function! Dbclearall()
    call system('ts -t '''.g:matlab_pane.''' dbclear all')
    silent! sign unplace *
    set ma
endfunction
command! Dbclearall :call Dbclearall()

"}}}--------------------------------------------------------------------------
"       Quit debugging mode {{{
"-----------------------------------------------------------------------------
function! Dbquit()
    " Send dbquit to matlab
    call system('ts -t '''.g:matlab_pane.''' dbquit')

    " Remove debugging cursor marker
    silent! sign unplace 1

    " Make file modifiable again
    set ma
endfunction
command! Dbquit :call Dbquit()

"}}}--------------------------------------------------------------------------
"       Dbstep and move cursor to next line of executable code {{{
"-----------------------------------------------------------------------------
function! Dbstep()
    " Unplace sign at current cursor position
    silent! sign unplace 1

    " Make debugging step
    call system('ts -t '''.g:matlab_pane.''' dbstep')

    " Return line on which debugger has stopped
    "    Read MATLAB window debugger output i.e.:
    "      37      f1 = f(z(:,:,i));
    "      K>> dbstep
    "      38      f2 = f(z(:,:,i)+(h/2)*f1);
    "      K>>
    "    and grep for lines starting with numbers, then read last number
    let lnr = system('tmux capture-pane -p -t '''.g:matlab_pane.''' | grep -o "^\<[0-9]\+\>" | tail -n 1')

    " " move cursor to next line, first column with non-whitespace character
    " call cursor(lnr,0) | norm! ^
    exe ":silent! sign place 1 line=".lnr." name=piet file=".expand("%:p")
endfunction
command! Dbstep :call Dbstep()

"}}}--------------------------------------------------------------------------
"       Evaluate current selection {{{
"-----------------------------------------------------------------------------
function! EvaluateSelection()
    let mcom = s:GetVisualSelection()
    " Only need to escape ; if there is no space after it (not sure why?)
    let mcom = substitute(mcom, ';', '; ', 'g')
    " Need to escape `%' so vim doesn't insert filename
    let mcom = substitute(mcom, '%', '\%', 'g')
    " Change newlines to literal carriage return so shellescape() does not
    " escape them (sends literal \ to tmux send-keys)
    let mcom = substitute(mcom, "\n", '\', 'g')
    " Call shellescape() for proper treatment of string characters
    call system('ts -t '''.g:matlab_pane.''' '.shellescape(mcom))
endfunction
command! -range EvaluateSelection :call EvaluateSelection()

"}}}--------------------------------------------------------------------------
"       GetVisualSelection Return string of visual selection {{{
"----------------------------------------------------------------------------
function! s:GetVisualSelection()
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
    return join(lines, "\n")
endfunction

"}}}--------------------------------------------------------------------------
"       cd in MATLAB to directory of current file {{{
"-----------------------------------------------------------------------------
function! CdMatlab()
    " Use cd('full path') form to deal with spaces, etc. in filenames
    let mcom = 'cd('''.expand("%:p:h").''')'
    call system('ts -t '''.g:matlab_pane.''' '.shellescape(mcom))
endfunction
command! CdMatlab :call CdMatlab()

"}}}--------------------------------------------------------------------------
"       Keymaps {{{
"-----------------------------------------------------------------------------
" Map \M to make in background
" nnoremap <buffer> <localleader>M :LintAndRunMatlabScript<CR>
nnoremap <buffer> <localleader>M :RunMatlabScript<CR>
nnoremap <buffer> <localleader>L :LintMatlabScript<CR>

" Evaluate Current selection
vnoremap <localleader>e :EvaluateSelection<CR>

" Debugging
nnoremap <buffer> <localleader>b :Dbstop<CR>
nnoremap <buffer> <localleader>S :call system('ts -t '''.g:matlab_pane.''' dbstatus')<CR>
nnoremap <buffer> <localleader>c :Dbclear<CR>
nnoremap <buffer> <localleader>C :Dbclearall<CR>
nnoremap <buffer> <localleader>q :Dbquit<CR>
" nnoremap <buffer> <localleader>Q :Dbquit<bar>Dbclearall<CR>
nnoremap <buffer> <localleader>n :Dbstep<CR>
nnoremap <buffer> <localleader>r :call system('ts -t '''.g:matlab_pane.''' dbcont')<CR>

" Call Matlab help on current word, or whos on variable
" TODO include 'whodat.m' in package
nnoremap <buffer> <localleader>h :call system('ts -t '''.g:matlab_pane.''' "help <C-R><C-W>"')<CR>
" nnoremap <buffer> <localleader>w :call system('ts -t '''.g:matlab_pane.''' "whos <C-R><C-W>"')<CR>
nnoremap <buffer> <localleader>w :call system('ts -t '''.g:matlab_pane.''' "whodat <C-R><C-W>"')<CR>
" nnoremap <buffer> <localleader>W :call system('ts -t '''.g:matlab_pane.''' "whos"')<CR>
nnoremap <buffer> <localleader>W :call system('ts -t '''.g:matlab_pane.''' "whodat"')<CR>

" Just hit "Enter" on a variable to display it in console
nnoremap <buffer> <localleader> :call system('ts -t '''.g:matlab_pane.''' "<C-R><C-W>"')<CR>

" Change matlab directory
nnoremap <buffer> <localleader>d :CdMatlab<CR>

" Make line into a comment header with dashes
" let @h='o%79a-yypO%8a '
let @h='O%79a-jI%8a o%79a-k$'

" Following function does NOT work when "comments" is set because newline
"+ characters insert additional leader character
" inoremap %%% <C-R>=CommentHeader(input("Enter header: "), '%', '-')<CR>
" }}}

" vim:fdm=marker
"=============================================================================
"=============================================================================

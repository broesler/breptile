"=============================================================================
"     File: breptile/ftplugin/matlab/matlab.vim
"   Author: Bernie Roesler
"  Created: 12/07/15, 12:27
"
" Last Modified: 05/16/2016, 10:10
"
"  Description: MATLAB filetype settings and mappings
"=============================================================================
if exists("g:matlab_pane") && g:matlab_pane
    let b:breptile_tmuxpane = b:breptile_tmuxpane
endif

" Search pattern for gnuplot pane
" let b:tpgrep_pat = get(b:, 'tpgrep_pat', '/Applications/[M]ATLAB')
let b:tpgrep_pat = get(b:, 'tpgrep_pat', '[r]lwrap.*matlab')

"}}}
function! MatlabCd() "{{{
    " Use cd('full path') form to deal with spaces, etc. in filenames
    let mcom = 'cd(''' . expand("%:p:h") . ''')'
    call system('ts -t ''' . b:breptile_tmuxpane . ''' ' . shellescape(mcom))
endfunction
"}}}
function! MatlabLintScript() "{{{
    " TODO try this with ALE async linter? Or write my own?
    " TODO make full Matlab path a script variable

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

    let &l:makeprg="/Applications/MATLAB_R2015b.app/bin/maci64/mlint -id "
                \.shellescape(expand("%:p")).' '.shellescape(expand("%:p:r"))

    " List efm most restrictive to least restrictive patterns
    " let &l:errorformat="%EL %l (C %c%.%#): Parse error%.%#: %m,"
    "             \ . "%EL %l (C %c%.%#): Invalid syntax at '%s'%.%#. %m,"
    "             \ . "%WL %l (C %c%.%#): %m"
    let &l:errorformat= "%P==========\ %f\ ==========,"
          \ . "%-G%>==========\ %s\ ==========,"
          \ . "%-G%>L\ %l\ (C\ %c):\ MDOTM%m,"
          \ . "L\ %l\ (C\ %c):\ %m,"
          \ . "L\ %l\ (C\ %c-%*[0-9]):\ %m,"
          \ . "%-Q"

    " save changes made to the file so Matlab gets the most recent version
    update | silent! make! | redraw!
endfunction
"}}}
function! MatlabRunScript() "{{{
    " TODO move this function to a generic breptile function
    " Check if Matlab is running!
    if strlen(b:breptile_tmuxpane) == 0
        echohl WarningMsg 
              \| echom 'WARNING: Matlab is not running!' 
              \| echohl None
        return -1
    end
    
    let mpane = substitute(b:breptile_tmuxpane, '%','\\%', 'g')
    let &l:makeprg='ts -t ''' . mpane . ''' ' . shellescape(expand("%:t:r"))

    " NOTE: efm will not do anything with &l:makeprg set to "ts -t..." because
    " just sending keys to tmux will not report anything back to the vim pane
    "
    " List efm most restrictive to least restrictive patterns
    let &l:errorformat="%WWarning: %m,%Z> in %f (line %l),"
                \ . "%ZError in %f (line %l),%+EError using%.%#,%C%m,%-G%.%#"
    " \ . "%EError: File: %f Line: %l Column: %c,%Z%m"

    " save changes made to the file so Matlab gets the most recent version
    update | silent! make! | redraw!
endfunction
"}}}

" Define signs for debugging stops {{{
hi clear SignColumn
hi default DebugStopHL ctermfg=red
hi link DebugCursorHL Search
sign define dbstop text=$$ texthl=DebugStopHL
sign define piet   text=>> texthl=DebugCursorHL
"}}}
function! MatlabDbstop() "{{{
    write %
    let lnr = line('.')
    let mcom = "dbstop in " . expand("%") . " at " . lnr
    call system('ts -t ''' . b:breptile_tmuxpane . ''' ' . mcom)
    " place sign at dbstop current line, use lnr as ID
    exe ":silent sign place " . lnr . " line=" . lnr . " name=dbstop file=" . expand("%:p")
    " keep file from being modified during debugging
    set noma
endfunction
"}}}
function! MatlabDbclear() "{{{
    let mcom = "dbclear in " . expand("%") . " at " . line(".")
    call system('ts -t ''' . b:breptile_tmuxpane . ''' ' . mcom)
    silent! sign unplace
endfunction
"}}}
function! MatlabDbclearall() "{{{
    call system('ts -t ''' . b:breptile_tmuxpane . ''' dbclear all')
    silent! sign unplace *
    set ma
endfunction
"}}}
function! MatlabDbquit() "{{{
    " Send dbquit to matlab
    call system('ts -t ''' . b:breptile_tmuxpane . ''' dbquit')

    " Remove debugging cursor marker
    silent! sign unplace 1

    " Make file modifiable again
    set ma
endfunction
"}}}
function! MatlabDbstep() "{{{
    " Unplace sign at current cursor position
    silent! sign unplace 1

    " Make debugging step
    call system('ts -t ''' . b:breptile_tmuxpane . ''' dbstep')

    " Return line on which debugger has stopped
    "    Read MATLAB window debugger output i.e.:
    "      37      f1 = f(z(:,:,i));
    "      K>> dbstep
    "      38      f2 = f(z(:,:,i)+(h/2)*f1);
    "      K>>
    "    and grep for lines starting with numbers, then read last number
    let lnr = system('tmux capture-pane -p -t ''' . b:breptile_tmuxpane . ''' | grep -o "^\<[0-9]\+\>" | tail -n 1')

    " " move cursor to next line, first column with non-whitespace character
    " call cursor(lnr,0) | norm! ^
    exe ":silent! sign place 1 line=" . lnr . " name=piet file=" . expand("%:p")
endfunction
"}}}

"-----------------------------------------------------------------------------
"       Keymaps {{{
"-----------------------------------------------------------------------------
command! -buffer -bar MatlabLintScript :call MatlabLintScript()
command! -buffer -bar MatlabRunScript  :call MatlabRunScript()
command! -buffer -bar MatlabDbstop     :call MatlabDbstop()
command! -buffer -bar MatlabDbclear    :call MatlabDbclear()
command! -buffer -bar MatlabDbclearall :call MatlabDbclearall()
command! -buffer -bar MatlabDbquit     :call MatlabDbquit()
command! -buffer -bar MatlabDbstep     :call MatlabDbstep()
command! -buffer -bar MatlabCd         :call MatlabCd()

" Running the script
nnoremap <buffer> <localleader>M :MatlabRunScript<CR>
nnoremap <buffer> <localleader>L :MatlabLintScript<CR>

" Debugging
nnoremap <buffer> <localleader>b :MatlabDbstop<CR>
nnoremap <buffer> <localleader>S :call system('ts -t ''' . b:breptile_tmuxpane . ''' dbstatus')<CR>
nnoremap <buffer> <localleader>c :MatlabDbclear<CR>
nnoremap <buffer> <localleader>C :MatlabDbclearall<CR>
nnoremap <buffer> <localleader>q :MatlabDbquit<CR>
nnoremap <buffer> <localleader>n :MatlabDbstep<CR>
" nnoremap <buffer> <localleader>Q :MatlabDbquit<bar>MatlabDbclearall<CR>
nnoremap <buffer> <localleader>r :call system('ts -t ''' . b:breptile_tmuxpane . ''' dbcont')<CR>

" Call Matlab help on current word, or whos on variable
" TODO include 'whodat.m' in package
nnoremap <buffer> <localleader>h :call system('ts -t ''' . b:breptile_tmuxpane . ''' "help <C-R><C-W>"')<CR>
nnoremap <buffer> <localleader>w :call system('ts -t ''' . b:breptile_tmuxpane . ''' "whodat <C-R><C-W>"')<CR>
nnoremap <buffer> <localleader>W :call system('ts -t ''' . b:breptile_tmuxpane . ''' "whodat"')<CR>
" Standard usage:
" nnoremap <buffer> <localleader>w :call system('ts -t ''' . b:breptile_tmuxpane . ''' "whos <C-R><C-W>"')<CR>
" nnoremap <buffer> <localleader>W :call system('ts -t ''' . b:breptile_tmuxpane . ''' "whos"')<CR>

" display variable in console
nnoremap <buffer> <localleader><CR> system('ts -t ''' . b:breptile_tmuxpane . ''' "<C-R><C-W>"')<CR>

" Change matlab directory
nnoremap <buffer> <localleader>d :MatlabCd<CR>

" Make line into a comment header with dashes
augroup headers "{{{
    au!
    autocmd BufEnter *.m let @h = 'O%' . expand(&textwidth-col('.')-1) . 'a-jI%8a o%' . expand(&textwidth-col('.')-1) . 'a-k$'
augroup END
"}}}

"}}}

" vim:fdm=marker
"=============================================================================
"=============================================================================

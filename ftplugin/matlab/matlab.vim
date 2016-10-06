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
    let b:breptile_tmuxpane = g:matlab_pane
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

"-----------------------------------------------------------------------------
"       Keymaps {{{
"-----------------------------------------------------------------------------
command! -buffer -bar MatlabLintScript :call MatlabLintScript()
command! -buffer -bar MatlabRunScript  :call MatlabRunScript()
command! -buffer -bar MatlabDbstop     :call matlab#debug#Dbstop()
command! -buffer -bar MatlabDbclear    :call matlab#debug#Dbclear()
command! -buffer -bar MatlabDbclearall :call matlab#debug#Dbclearall()
command! -buffer -bar MatlabDbquit     :call matlab#debug#Dbquit()
command! -buffer -bar MatlabDbstep     :call matlab#debug#Dbstep()
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

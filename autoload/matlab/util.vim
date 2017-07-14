"=============================================================================
"     File: util.vim
"  Created: 10/06/2016, 15:37
"   Author: Bernie Roesler
"
"  Description: 
"
"=============================================================================
if exists('g:loaded_breptile_matlab_util')
    finish
endif

function! matlab#util#MatlabCd() "{{{
    " Use cd('full path') form to deal with spaces, etc. in filenames
    let mcom = 'cd(''' . expand("%:p:h") . ''')'
    call system('ts -t ''' . b:breptile_tmuxpane . ''' ' . shellescape(mcom))
endfunction
"}}}
function! matlab#util#MatlabLintScript() "{{{
    " TODO try this with ALE async linter? Or write my own?
    " TODO make full Matlab path a script variable

    " Give <filename.m> <empty-string> to make mlint print filenames
    " mlint doesn't provide filename information except if multiple
    " filenames are given 
    " With the following command :
    " mlint <filename> <empty-string>
    " mlint produces an output like that :
    " ========== <filename> ==========
    " L x (C y): ID : Message
    " L x (C y): ID : Message
    " ..
    " ..
    " ========== <empty-string> ==========

    let &l:makeprg="/Applications/MATLAB_R2016b.app/bin/maci64/mlint -id "
                \.shellescape(expand("%:p"))." ''"

    " List efm most restrictive to least restrictive patterns
    let &l:errorformat= "%P==========\ %f\ ==========,"
          \ . "L\ %l\ (C\ %c):\ %m,"
          \ . "L\ %l\ (C\ %c-%*[0-9]):\ %m,"
          \ . "%-Q"

    " save changes made to the file so Matlab gets the most recent version
    update | silent! make! | redraw!
endfunction
"}}}

let g:loaded_breptile_matlab_util = 1
" vim:fdm=marker

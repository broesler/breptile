"=============================================================================
"     File: breptile/ftplugin/matlab/mappings.vim
"   Author: Bernie Roesler
"  Created: 12/07/15, 12:27
"
" Last Modified: 05/16/2016, 10:10
"
"  Description: MATLAB filetype settings and mappings
"=============================================================================
if exists('g:loaded_breptile_matlab')
    finish
end

"-----------------------------------------------------------------------------
"       Commands and Keymaps
"-----------------------------------------------------------------------------
command! -buffer -bar MatlabCd         :call matlab#util#MatlabCd()
command! -buffer -bar MatlabLintScript :call matlab#util#MatlabLintScript()
command! -buffer -bar MatlabRunScript  :call matlab#util#MatlabRunScript()
command! -buffer -bar MatlabDbstop     :call matlab#debug#Dbstop()
command! -buffer -bar MatlabDbclear    :call matlab#debug#Dbclear()
command! -buffer -bar MatlabDbclearall :call matlab#debug#Dbclearall()
command! -buffer -bar MatlabDbquit     :call matlab#debug#Dbquit()
command! -buffer -bar MatlabDbstep     :call matlab#debug#Dbstep()

if g:breptile_mapkeys_matlab "{{{
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
    augroup headers
        au!
        autocmd BufEnter *.m let @h = 'O%' . expand(&textwidth-col('.')-1) 
                      \ . 'a-jI%8a o%' . expand(&textwidth-col('.')-1) 
                      \ . 'a-k$'
    augroup END
endif
"}}}

let g:loaded_breptile_matlab = 1
"=============================================================================
"=============================================================================

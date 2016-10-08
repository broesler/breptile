"=============================================================================
"     File: sections.vim
"  Created: 10/02/2016, 19:17
"   Author: Bernie Roesler
"
"  Description: Control section movements in matlab files
"
"=============================================================================
if exists("g:loaded_breptile_matlab_sections")
    finish
endif

function! s:NextSection(type, backwards, visual)
    if a:visual
        normal! gv
    endif

    if a:type == 1
        " In Matlab %% gives a 'section' header
        let pattern ='\v(^\s*\%\%(\s|$)|%^)'
        let flags = ''     " 'e' move to end of pattern
    elseif a:type == 2
        let pattern ='\v(\n^\s*\%\%(\s|$)|%$)'
        let flags = ''
    endif

    if a:backwards
        let dir = '?'
    else
        let dir = '/'
    endif

    " let save_wrapscan = &wrapscan
    " set nowrapscan
    execute 'silent normal! ' . dir . pattern . dir . flags . "\r"
    " let &wrapscan = save_wrapscan
endfunction

" Maps that work as movements and motions
noremap <script> <buffer> <silent> ]] :call <SID>NextSection(1, 0, 0)<CR>
noremap <script> <buffer> <silent> [[ :call <SID>NextSection(1, 1, 0)<CR>
noremap <script> <buffer> <silent> ][ :call <SID>NextSection(2, 0, 0)<CR>
noremap <script> <buffer> <silent> [] :call <SID>NextSection(2, 1, 0)<CR>

" Visual mappings
vnoremap <script> <buffer> <silent> ]] :<C-u>call <SID>NextSection(1, 0, 1)<CR>
vnoremap <script> <buffer> <silent> [[ :<C-u>call <SID>NextSection(1, 1, 1)<CR>
vnoremap <script> <buffer> <silent> ][ :<C-u>call <SID>NextSection(2, 0, 1)<CR>
vnoremap <script> <buffer> <silent> [] :<C-u>call <SID>NextSection(2, 1, 1)<CR>

let g:loaded_breptile_matlab_sections = 1
"=============================================================================
"=============================================================================

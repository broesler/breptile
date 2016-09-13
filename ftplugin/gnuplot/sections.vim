"=============================================================================
"     File: sections.vim
"  Created: 09/12/2016, 21:48
"   Author: Bernie Roesler
"
"  Description: Control section movements in gnuplot files
"
"=============================================================================

function! s:NextSection(type, backwards)
  if a:type == 1
    let pattern = '\v(\n\n^\S|%^)'
  elseif a:type == 2
    let pattern = 'two'
  endif

  if a:backwards
    let dir = '?'
  else
    let dir = '/'
  endif

  execute 'silent normal! ' . dir . pattern . "\r"
endfunction

noremap <script> <buffer> <silent> ]] :call <SID>NextSection(1, 0)<CR>
noremap <script> <buffer> <silent> [[ :call <SID>NextSection(1, 1)<CR>
noremap <script> <buffer> <silent> ][ :call <SID>NextSection(2, 0)<CR>
noremap <script> <buffer> <silent> [] :call <SID>NextSection(2, 1)<CR>

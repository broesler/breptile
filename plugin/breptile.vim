"=============================================================================
"     File: breptile/plugin/breptile.vim
"  Created: 09/15/2016, 19:26
"   Author: Bernie Roesler
"
"  Description: Main script for this plugin. Defines maps and commands for
"  running commands/scripts in any tmux pane (except the one running vim!).
"
"=============================================================================
if exists("g:loaded_breptile") || &cp || (strlen($TMUX) == 0)
  finish
endif

"-----------------------------------------------------------------------------
"       Configuration  {{{
"-----------------------------------------------------------------------------
if !exists("g:breptile_mapkeys")
    let g:breptile_mapkeys = 0
endif

if !exists("g:breptile_usetpgrep")
    let g:breptile_usetpgrep = 0
endif

"}}}--------------------------------------------------------------------------
"       Commands and Key maps {{{
"-----------------------------------------------------------------------------
" Run the entire script
command! -nargs=? -complete=file BReptileRunScript call breptile#RunScript(<f-args>)

" Find program pane manually
command! -nargs=? BReptileFindPane call breptile#UpdateProgramPane(<f-args>)

" Sends lines to REPL
command! -count      BReptileSendCount  call breptile#SendCount(<count>)
command! -range -bar BReptileSendRange  <line1>,<line2>call breptile#SendRange()

" User uses these maps in their vimrc:
if g:breptile_mapkeys
    " ALLOW recursion here so that <Plug>s work properly
    nmap <silent> <localleader>e <Plug>BReptileSendOpNorm
    vmap <silent> <localleader>e <Plug>BReptileSendOpVis

    nnoremap <silent> <localleader>M :BReptileRunScript<CR>
endif
"}}}
" Set up autocmd to find the pane {{{
if g:breptile_usetpgrep 
   " Set up autocmd to find the pane running the program
   augroup BReptileFindPane
       autocmd!
       autocmd Filetype gnuplot,matlab,sh BReptileFindPane
   augroup END
else
    " Just call it once
    BReptileFindPane
endif
"}}}

let g:loaded_breptile = 1
"=============================================================================
"=============================================================================

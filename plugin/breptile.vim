"=============================================================================
"     File: breptile/plugin/breptile.vim
"  Created: 09/15/2016, 19:26
"   Author: Bernie Roesler
"
"  Description: Main script for this plugin. Defines maps and commands for
"  running commands/scripts in any tmux pane (except the one running vim!).
"
"=============================================================================
" Comment out to reload while debugging
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
command! -nargs=? -complete=file BRRunScript update | call breptile#RunScript(<f-args>)

" Get the configuration variables
command! BRGetConfig call breptile#GetConfig()

" Find program pane manually (give tpgrep_pat)
command! -nargs=? BRFindPane call breptile#UpdateProgramPane(<f-args>)

" Sends lines to REPL
command! -count      BRSendCount  call breptile#SendCount(<count>)
command! -range -bar BRSendRange  <line1>,<line2>call breptile#SendRange()

" User uses these maps in their vimrc:
if g:breptile_mapkeys
    " ALLOW recursion here so that <Plug>s work properly
    nmap <silent> <localleader>e <Plug>BRSendOpNorm
    vmap <silent> <localleader>e <Plug>BRSendOpVis

    nnoremap <silent> <localleader>R :BRRunScript<CR>
endif
"}}}
" Set up autocmd to find the pane {{{
if g:breptile_usetpgrep 
   " Set up autocmd to find the pane running the program
   augroup BRFindPane
       autocmd!
       autocmd Filetype gnuplot,matlab,python,sh,scheme BRGetConfig
   augroup END
else
    " Just call it once
    BRGetConfig
endif
"}}}

let g:loaded_breptile = 1
"=============================================================================
"=============================================================================

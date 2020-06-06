"=============================================================================
"     File: breptile/plugin/breptile.vim
"  Created: 09/15/2016, 19:26
"   Author: Bernie Roesler
"
"  Description: Main script for this plugin. Defines maps and commands for
"  running commands/scripts in any tmux pane (except the one running vim!).
"
"=============================================================================
"
if exists("g:loaded_breptile") || &cp || (strlen($TMUX) == 0)
  finish
endif

"-----------------------------------------------------------------------------
"       Configuration  {{{
"-----------------------------------------------------------------------------
if !exists('g:breptile_mapkeys')
    let g:breptile_mapkeys = 1
endif

if !exists('g:breptile_usetpgrep')
    let g:breptile_usetpgrep = 1
endif

if !exists('g:breptile_vimpane')
    " Track vim's pane, so we don't accidentally send commands to it
    let g:breptile_vimpane = system('tpgrep vim')[:-2]
endif

"}}}--------------------------------------------------------------------------
"       Commands and Key maps {{{
"-----------------------------------------------------------------------------
" TODO add these commands to documentation and remove comments to clean up
" Run the entire script
command! -nargs=? -complete=file BRRunScript update | call breptile#RunScript(<f-args>)

" Get the configuration variables
" Args are: [tpgrep_pat] [verbose (logical)]
command! -nargs=* -bang BRGetConfig call breptile#GetConfig(<bang>0, <f-args>)

" Sends lines to REPL
command! -count BRSendCount call breptile#SendCount(<count>)
command! -range -bar BRSendRange  <line1>,<line2>call breptile#SendRange()

" Send arbitrary text to local tmuxpane
command! -nargs=1 BRTmuxSend call breptile#TmuxSendwithReturn(b:breptile_tmuxpane, <args>)

" User uses these maps in their vimrc:
if g:breptile_mapkeys
    " TODO use :exe "nmap ... " . g:breptile#user_command . "<Plug>etc"
    " TODO figure out how to make these mappings buffer-local, only for
    " filetypes that BReptile supports.
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
       autocmd Filetype gnuplot,python,matlab,r,sh,scheme BRGetConfig
   augroup END
else
    " Just call it once
    BRGetConfig
endif
"}}}

let g:loaded_breptile = 1
"=============================================================================
"=============================================================================

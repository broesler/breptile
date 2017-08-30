"=============================================================================
"     File: breptile/ftplugin/sh.vim
"  Created: 10/07/2016, 20:35
"   Author: Bernie Roesler
"
"  Description: Settings for shell scripts
"
"=============================================================================
" Configuration "{{{
" Gnuplot script-running command
let b:breptile_runfmt = get(g:, 'b:breptile_sh_runfmt', "./'%s'")

" Directly set pane if it exists and is non-empty
if exists("g:breptile_bash_pane") && strlen("g:breptile_bash_pane") > 0
    let b:breptile_tmuxpane = g:breptile_bash_pane
endif

" Search pattern for bash pane
let b:breptile_tpgrep_pat = get(g:, 'breptile_tpgrep_pat_bash', '/[u]sr/local/bin/bash')
"}}}
"=============================================================================
"=============================================================================

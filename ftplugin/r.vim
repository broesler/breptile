"=============================================================================
"     File: ftplugin/r.vim
"  Created: 2020-06-05 19:33
"   Author: Bernie Roesler
"
"  Description: Buffer settings for R script files
"
"=============================================================================

" Configuration
let b:breptile_runfmt = get(g:, "g:breptile_R_runfmt", 'source("%s")')

" Directly set pane if it exists and is non-empty
if exists("g:R_pane") && strlen("g:R_pane") > 0
    let b:breptile_tmuxpane = g:R_pane
endif

" Search pattern for R pane
let b:breptile_tpgrep_pat = get(g:, 'breptile_tpgrep_pat_R', '\<R\>')

" R error looks like:
"   Error in log("a") : non-numeric argument to mathematical function
let b:R_errorformat="Error in %f#%l: %m"

" Need to use R> load "filename.gpi"
let b:R_makeprg = 'source("' . expand("%:t") . '")'

"=============================================================================
"=============================================================================

## BReptile

A vim plugin for running your [REP]ti[L]e programs without copy/paste.

## Installation

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then run:

```bash
    cd ~/.vim/bundle
    git clone https://github.com/broesler/breptile.git
```

Once help tags have been generated, you can view the manual with
`:help breptile`.


## Info
Once I fell in love with Vim, I couldn't bear using the Matlab editor/console
interface for running code anymore. I modeled this simple interface off of the
ideas in [vim-slime](https://github.com/jpalardy/vim-slime), with the main
additional feature of automagically finding the tmux pane in which your REPL is
running. I've also included Matlab console support including some basic
debugging commands and maps. Still a work in progress!

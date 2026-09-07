" Neovim entry point.
"
" The real config is the shared vimrc in this repo, so vim and neovim
" behave the same. Neovim looks in ~/.config/nvim and not in ~/.vim, so
" add ~/.vim to the runtimepath before we source the vimrc.

set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
let &packpath = &runtimepath

source ~/.vim/vimrc

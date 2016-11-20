#!/bin/sh

rootdir=$(readlink -f $(dirname $0))

curl -fLo ${rootdir}/plug.vim --create-dirs \
   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall

echo "Finished installing autoload/bundle"

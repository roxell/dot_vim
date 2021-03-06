#!/bin/bash

reporoot=$(readlink -f $(dirname $0))

[[ -f install-lib ]] || curl -sSOL https://raw.githubusercontent.com/roxell/local-inst-lib/master/install-lib
source install-lib

install_files=(
    "$HOME/.vim:${reporoot}"
    "$HOME/.vimrc:${reporoot}/vimrc"
    "$HOME/bin/haste:${reporoot}/haste"
)

mkdir -p $HOME/bin

create_symlink

mkdir -p $HOME/.vim/bundle
${reporoot}/autoload/install.sh

###############################################################################
# vim: set ts=4 sw=4 sts=4 et                                                 :

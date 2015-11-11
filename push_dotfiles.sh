# !/usr/bin/env bash

rm -f ~/.bash_profile
rm -f ~/.bashrc
rm -f ~/.git-prompt.sh
rm -f ~/.gitconfig
rm -f ~/.gitignore_global
rm -f ~/.inputrc
rm -f ~/.gnupg/gpg.conf
rm -f ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings

DOTFILE_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd ) # absolute path to dir

ln -s "${DOTFILE_DIR}/bash_profile" ~/.bash_profile
ln -s "${DOTFILE_DIR}/bashrc" ~/.bashrc
ln -s "${DOTFILE_DIR}/git-prompt.sh" ~/.git-prompt.sh
ln -s "${DOTFILE_DIR}/gitconfig" ~/.gitconfig
ln -s "${DOTFILE_DIR}/gitignore_global" ~/.gitignore_global
ln -s "${DOTFILE_DIR}/inputrc" ~/.inputrc
ln -s "${DOTFILE_DIR}/gpg.conf" ~/.gnupg/
ln -s "${DOTFILE_DIR}/Preferences.sublime-settings" ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
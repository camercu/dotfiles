# !/usr/bin/env bash

rm -f ~/.bash_profile
rm -f ~/.bashrc
rm -f ~/.git-prompt.sh
rm -f ~/.gitconfig
rm -f ~/.gitignore_global
rm -f ~/.inputrc
rm -f ~/.gnupg/gpg.conf
rm -f ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings


ln -s ~/.dotfiles/bash_profile ~/.bash_profile
ln -s ~/.dotfiles/bashrc ~/.bashrc
ln -s ~/.dotfiles/git-prompt.sh ~/.git-prompt.sh
ln -s ~/.dotfiles/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/gitignore_global ~/.gitignore_global
ln -s ~/.dotfiles/inputrc ~/.inputrc
ln -s ~/.dotfiles/gpg.conf ~/.gnupg/
ln -s ~/.dotfiles/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
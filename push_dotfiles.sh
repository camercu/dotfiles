# !/usr/bin/env bash

rm -f ~/.bash_profile
rm -f ~/.bashrc
rm -f ~/.git-prompt.sh
rm -f ~/.gitconfig
rm -f ~/.gitignore_global
rm -f ~/.inputrc
rm -f ~/.gnupg/gpg.conf
rm -f ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings


ln -s "$(pwd)/bash_profile" ~/.bash_profile
ln -s "$(pwd)/bashrc" ~/.bashrc
ln -s "$(pwd)/git-prompt.sh" ~/.git-prompt.sh
ln -s "$(pwd)/gitconfig" ~/.gitconfig
ln -s "$(pwd)/gitignore_global" ~/.gitignore_global
ln -s "$(pwd)/inputrc" ~/.inputrc
ln -s "$(pwd)/gpg.conf" ~/.gnupg/
ln -s "$(pwd)/Preferences.sublime-settings" ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
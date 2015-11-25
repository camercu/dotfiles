# !/usr/bin/env bash

DOTFILE_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd ) # absolute path to dir
ARCHIVE_DIR="${DOTFILE_DIR}/old"

subl_settings_dir=~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
subl_settings=${subl_settings_dir}/Preferences.sublime-settings

[[ -d $ARCHIVE_DIR ]] && mkdir $ARCHIVE_DIR

[[ -f ~/.bash_profile ]] && mv ~/.bash_profile $ARCHIVE_DIR
[[ -f ~/.bashrc ]] && mv ~/.bashrc $ARCHIVE_DIR
[[ -f ~/.git-prompt.sh ]] && mv ~/.git-prompt.sh $ARCHIVE_DIR
[[ -f ~/.gitconfig ]] && mv ~/.gitconfig $ARCHIVE_DIR
[[ -f ~/.gitignore_global ]] && mv ~/.gitignore_global $ARCHIVE_DIR
[[ -f ~/.inputrc ]] && mv ~/.inputrc $ARCHIVE_DIR
[[ -f ~/.gnupg/gpg.conf ]] && mv ~/.gnupg/gpg.conf $ARCHIVE_DIR
[[ -f $subl_settings ]] && mv $subl-settings $ARCHIVE_DIR

ln -s "${DOTFILE_DIR}/bash_profile" ~/.bash_profile
ln -s "${DOTFILE_DIR}/bashrc" ~/.bashrc
ln -s "${DOTFILE_DIR}/git-prompt.sh" ~/.git-prompt.sh
ln -s "${DOTFILE_DIR}/gitconfig" ~/.gitconfig
ln -s "${DOTFILE_DIR}/gitignore_global" ~/.gitignore_global
ln -s "${DOTFILE_DIR}/inputrc" ~/.inputrc
ln -s "${DOTFILE_DIR}/gpg.conf" ~/.gnupg/
ln -s "${DOTFILE_DIR}/Preferences.sublime-settings" $subl_settings_dir

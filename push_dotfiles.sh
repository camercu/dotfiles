# !/usr/bin/env bash

DOTFILE_DIR=$(\cd $(\dirname ${BASH_SOURCE[0]}) && \pwd ) # absolute path to dir
ARCHIVE_DIR="${DOTFILE_DIR}/old"

# make archive dir if doesn't exist
[[ -d $ARCHIVE_DIR ]] || mkdir -p "$ARCHIVE_DIR"

# back up existing dotfiles
[[ -f ~/.bash_profile && ! -L ~/.bash_profile ]] && \
	mv ~/.bash_profile "$ARCHIVE_DIR"
[[ -f ~/.bashrc && ! -L ~/.bashrc ]] && \
	mv ~/.bashrc "$ARCHIVE_DIR"
[[ -f ~/.bash_aliases && ! -L ~/.bash_aliases ]] && \
        mv ~/.bash_aliases "$ARCHIVE_DIR"
[[ -f ~/.vimrc && ! -L ~/.vimrc ]] && \
	mv ~/.vimrc "$ARCHIVE_DIR"
[[ -f ~/.gdbinit && ! -L ~/.gdbinit ]] && \
	mv ~/.gdbinit "$ARCHIVE_DIR"
[[ -f ~/.git-prompt.sh && ! -L ~/.git-prompt.sh ]] && \
	mv ~/.git-prompt.sh "$ARCHIVE_DIR"
[[ -f ~/.gitconfig && ! -L ~/.gitconfig ]] && \
	mv ~/.gitconfig "$ARCHIVE_DIR"
[[ -f ~/.gitignore_global && ! -L ~/.gitignore_global ]] && \
	mv ~/.gitignore_global "$ARCHIVE_DIR"
[[ -f ~/.inputrc && ! -L ~/.inputrc ]] && \
	mv ~/.inputrc "$ARCHIVE_DIR"
[[ -f ~/.nanorc && ! -L ~/.nanorc ]] && \
	mv ~/.nanorc "$ARCHIVE_DIR"

# symlink dotfiles
[[ -e ~/.bash_profile ]] || ln -s "${DOTFILE_DIR}/bash_profile" ~/.bash_profile
[[ -e ~/.bashrc ]] || ln -s "${DOTFILE_DIR}/bashrc" ~/.bashrc
[[ -e ~/.bash_aliases ]] || ln -s "${DOTFILE_DIR}/bash_aliases" ~/.bash_aliases
[[ -e ~/.vimrc ]] || ln -s "${DOTFILE_DIR}/vimrc" ~/.vimrc
[[ -e ~/.gdbinit ]] || ln -s "${DOTFILE_DIR}/gdbinit" ~/.gdbinit
[[ -e ~/.git-prompt.sh ]] || ln -s "${DOTFILE_DIR}/git-prompt.sh" ~/.git-prompt.sh
[[ -e ~/.gitconfig ]] || ln -s "${DOTFILE_DIR}/gitconfig" ~/.gitconfig
[[ -e ~/.gitignore_global ]] || ln -s "${DOTFILE_DIR}/gitignore_global" ~/.gitignore_global
[[ -e ~/.inputrc ]] || ln -s "${DOTFILE_DIR}/inputrc" ~/.inputrc
[[ ! -e ~/.gnupg/gpg.conf && -e ~/.gnupg ]] && ln -s "${DOTFILE_DIR}/gpg.conf" ~/.gnupg/
[[ -e ~/.nanorc ]] || ln -s "${DOTFILE_DIR}/nanorc" ~/.nanorc

# add Vundle to vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim


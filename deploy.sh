# !/usr/bin/env bash

DOTFILE_DIR=$(\cd $(\dirname ${BASH_SOURCE[0]}) && \pwd ) # absolute path to dir
ARCHIVE_DIR="${DOTFILE_DIR}/old"

# make archive dir if doesn't exist
[[ -d $ARCHIVE_DIR ]] || mkdir -p "$ARCHIVE_DIR"

# back up existing dotfiles
[[ -f ~/.gdbinit && ! -L ~/.gdbinit ]] && \
	mv ~/.gdbinit "$ARCHIVE_DIR"
[[ -f ~/.gitconfig && ! -L ~/.gitconfig ]] && \
	mv ~/.gitconfig "$ARCHIVE_DIR"
[[ -f ~/.gitconfig-aliases && ! -L ~/.gitconfig-aliases ]] && \
	mv ~/.gitconfig.aliases "$ARCHIVE_DIR"
[[ -f ~/.gitignore-global && ! -L ~/.gitignore-global ]] && \
	mv ~/.gitignore_global "$ARCHIVE_DIR"
[[ -f ~/.tmux.conf && ! -L ~/.tmux.conf ]] && \
	mv ~/.tmux.conf "$ARCHIVE_DIR"
[[ -f ~/.vimrc && ! -L ~/.vimrc ]] && \
    mv ~/.vimrc "$ARCHIVE_DIR"
[[ -f ~/.vimrc-plugs && ! -L ~/.vimrc-plugs ]] && \
    mv ~/.vimrc-plugs "$ARCHIVE_DIR"
[[ -d ~/.vim && ! -L ~/.vim ]] && \
    mv ~/.vim "$ARCHIVE_DIR"
[[ -f ~/.zshrc && ! -L ~/.zshrc ]] && \
	mv ~/.zshrc "$ARCHIVE_DIR"
[[ -f ~/.zsh-aliases && ! -L ~/.zsh-aliases ]] && \
	mv ~/.zsh-aliases "$ARCHIVE_DIR"

# symlink dotfiles
[[ -e ~/.gdbinit ]] || ln -s "${DOTFILE_DIR}/gdbinit" ~/.gdbinit
[[ -e ~/.gitconfig ]] || ln -s "${DOTFILE_DIR}/gitconfig" ~/.gitconfig
[[ -e ~/.gitconfig-aliases ]] || ln -s "${DOTFILE_DIR}/gitconfig-aliases" ~/.gitconfig-aliases
[[ -e ~/.gitignore-global ]] || ln -s "${DOTFILE_DIR}/gitignore-global" ~/.gitignore-global
[[ ! -e ~/.gnupg/gpg.conf && -e ~/.gnupg ]] && ln -s "${DOTFILE_DIR}/gpg.conf" ~/.gnupg/
[[ -e ~/.tmux.conf ]] || ln -s "${DOTFILE_DIR}/tmux.conf" ~/.tmux.conf
[[ -e ~/.vimrc ]] || ln -s "${DOTFILE_DIR}/vimrc" ~/.vimrc
[[ -e ~/.vimrc-plugs ]] || ln -s "${DOTFILE_DIR}/vimrc-plugs" ~/.vimrc-plugs
[[ -e ~/.vim ]] || ln -s "${DOTFILE_DIR}/.vim" ~/.vim
[[ -e ~/.zshrc ]] || ln -s "${DOTFILE_DIR}/zshrc" ~/.zshrc
[[ -e ~/.zsh-aliases ]] || ln -s "${DOTFILE_DIR}/zsh-aliases" ~/.zsh-aliases

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


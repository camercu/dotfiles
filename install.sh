#!/usr/bin/env bash

# To delete all dotfile symlinks in home folder (not perfect uninstaller):
# find ~ -maxdepth 1 -type l -name '.*' -delete

# obtain the absolute path of a file/dir
realpath () {
	local filename="$1"
	local parentdir=$(dirname "${filename}")

	if [ -d "${filename}" ]; then
		echo "$(cd "${filename}" && pwd -P)"
	elif [ -d "${parentdir}" ]; then
		echo "$(cd "${parentdir}" && pwd -P)/$(basename "$1")"
	fi
}

DOTFILE_DIR="$(cd "$(dirname ${0})" && pwd -P)" # absolute path to dir
ARCHIVE_DIR="${DOTFILE_DIR}/old"
OS="$(uname -s | tr '[:lower:]' '[:upper:]')"

# simple logging functions for printing output to stderr
source "${DOTFILE_DIR}/.logging.sh"


# backs up old dotfile and replaces it with symlink to one here.
# Usage: install_dotfile FILE [DEST]
#  FILE - the dotfile in this directory that you want to install
#  DEST - optional override of destination where dotfile will go. Defaults to home dir.
install_dotfile () {
	local src="$(realpath "$1")"
	local dst="${2:-"$HOME/$1"}"

	# back up existing file/dir if it exists and isn't a symlink
	if [[ -e "$dst" && ! -L "$dst" ]]; then
		backup="$(basename $dst.$(now)~)"
		debug "Backing up '$dst' at '$ARCHIVE_DIR/$backup'"
		mv "$dst" "$ARCHIVE_DIR/$backup"
	fi

	# symlink dotfile to destination
	if [[ ! -e "$dst" ]]; then
		debug "Symlinking: '$dst' -> '$src'"
		mkdir -p "$(dirname "$dst")"
		ln -sf "$src" "$dst"
	fi
}


# installs oh-my-zsh if not present, along with desired theme & plugins
install_ohmyzsh () {
	if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
		debug "Installing oh-my-zsh"
		sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi

	install_omz_extras () {
		local githubpath="https://github.com/$1"
		local item="$(basename $1)" # get repo name
		local it_type="${2:-plugin}" # should be either "plugin" or "theme"
		local parentdir="${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}/${it_type}s/${item}"
		if [[ ! -d "$parentdir" ]]; then
			debug "Installing oh-my-zsh $it_type: $item"
			git clone --depth=1 "$githubpath" "$parentdir"
		fi
	}

	install_omz_extras romkatv/powerlevel10k theme
	install_omz_extras zsh-users/zsh-autosuggestions
	install_omz_extras zsh-users/zsh-syntax-highlighting

	# hack that installs symlink to custom plugin
	install_dotfile hashcat-mode-finder "${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}/plugins/hashcat-mode-finder"
}

install_ohmytmux () {
	if [[ ! -d "$HOME/.tmux" ]]; then
		debug "Installing oh-my-tmux"
		git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
	fi

	install_dotfile "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
}

# make archive dir if doesn't exist
mkdir -p "$ARCHIVE_DIR"

# make user-local bin folder
USER_BIN="$HOME/.local/bin"
mkdir -p "$USER_BIN"

# install static-get script to user's bin dir
# static-get is a tool for grabbing static binaries (useful for pentesting)
install_dotfile bin/static-get "$USER_BIN/static-get"

# tools to make terminal nice
install_ohmyzsh
install_ohmytmux

COMMON_DOTFILES=(
	.gdbinit
	.gitconfig
	.gitconfig-aliases
	.gitignore-global
	.logging.sh
	.p10k.zsh
	.bash_aliases
	.zshrc
)

# install common dotfiles
for df in "${COMMON_DOTFILES[@]}"; do
	install_dotfile "$df"
done

MAC_DOTFILES=(
	.vim
	.vimrc
	.vimrc-plugs
)

# install MacOS-specific dotfiles
if [[ "$OS" == "DARWIN" ]]; then
	for df in "${MAC_DOTFILES[@]}"; do
		install_dotfile "$df"
	done

	# these require custom destinations, so can't use array (bash doesn't support 2D arrays)
	install_dotfile .gitconfig-credential-mac ~/.gitconfig-credential
	install_dotfile .tmux.conf.local.mac ~/.tmux.conf.local
fi

LINUX_DOTFILES=(
	.config/terminator/config
	.config/xfce4/helpers.rc
	.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
	.config/xfce4/panel/whiskermenu-1.rc
	.mozilla/firefox/addons.json
	.mozilla/firefox/installs.ini
	.mozilla/firefox/profiles.ini
	.mozilla/firefox/user.js
	.mozilla/firefox/extensions/{60f82f00-9ad5-4de5-b31c-b16a47c51558}.xpi
	.mozilla/firefox/extensions/foxyproxy@eric.h.jung.xpi
	.snmp
)

# install Linux-specific dotfiles
if [[ "$OS" == "LINUX" ]]; then
	for df in "${LINUX_DOTFILES[@]}"; do
		install_dotfile "$df"
	done

	install_dotfile .gitconfig-credential-linux ~/.gitconfig-credential
	install_dotfile .tmux.conf.local.linux ~/.tmux.conf.local

	if [[ ! -d ~/.ssh ]]; then
		mkdir ~/.ssh
		chmod 700 ~/.ssh
	fi

	if [[ ! -f ~/.ssh/config ]]; then
		cp .ssh/config ~/.ssh/config
	fi
fi

success DONE!

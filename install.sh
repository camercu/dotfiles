# !/usr/bin/env bash

DOTFILE_DIR=$(\cd $(\dirname ${BASH_SOURCE[0]}) && \pwd -P) # absolute path to dir
ARCHIVE_DIR="${DOTFILE_DIR}/old"
OS="$(uname -s | tr '[:lower:]' '[:upper:]')"

# simple logging functions for printing output to stderr
source .logging.sh

# make archive dir if doesn't exist
[[ -d $ARCHIVE_DIR ]] || mkdir -p "$ARCHIVE_DIR"

# obtain the absolute path of a file/dir
realpath () {
	local filename=$1
	local parentdir=$(dirname "${filename}")

	if [ -d "${filename}" ]; then
		echo "$(cd "${filename}" && pwd -P)"
	elif [ -d "${parentdir}" ]; then
		echo "$(cd "${parentdir}" && pwd -P)/$(basename "$1")"
	fi
}

# backs up old dotfile and replaces it with symlink to one here.
# Usage: install_dotfile FILE [DEST]
#  FILE - the dotfile in this directory that you want to install
#  DEST - optional override of destination where dotfile will go. Defaults to home dir.
install_dotfile () {
	local src="$(realpath "$1")"
	local dst="${2:-"$HOME/$(basename "$src")"}"

	# back up existing file/dir if it exists and isn't a symlink
	if [[ -e "$dst" && ! -L "$dst" ]]; then
		backup="$(basename $dst.$(now)~)"
		info "Backing up '$dst' -> '$ARCHIVE_DIR/$backup'"
		mv "$dst" "$ARCHIVE_DIR/$backup"
	fi

	# symlink dotfile to destination
	if [[ ! -e "$dst" ]]; then
		info "Installing symlink from '$src' to '$dst'"
		ln -sfw "$src" "$dst"
	fi
}

# installs oh-my-zsh if not present, along with desired theme & plugins
install_ohmyzsh () {
	if [[ ! -d ~/.oh-my-zsh ]]; then
		sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi

	function install_extra {
		local githubpath="https://github.com/$1"
		local item="$(basename $1)" # get repo name
		local it_type="${2:-plugin}" # should be either "plugin" or "theme"
		local parentdir="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/${it_type}s/${item}"
		if [[ ! -d "$parentdir" ]]; then
			git clone --depth=1 "$githubpath" "$parentdir"
		fi
	}

	install_extra romkatv/powerlevel10k theme
	install_extra zsh-users/zsh-autosuggestions
	install_extra zsh-users/zsh-syntax-highlighting

	# hack that installs symlink to custom plugin
	install_dotfile hashcat-mode-finder "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/"
}

COMMON_DOTFILES=(
	.gdbinit
	.gitconfig
	.gitconfig-aliases
	.gitignore-global
	.logging.sh
	.p10k.zsh
	.tmux.conf
	.zsh-aliases
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

	install_dotfile .gitconfig-credential-mac ~/.gitconfig-credential
fi

success DONE!

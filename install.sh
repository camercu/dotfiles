#!/usr/bin/env zsh

# To delete all dotfile symlinks in home folder (must run from zsh, not perfect uninstaller):
# rm -iv -- ~/*(D-@); rm -iv -- ~/.config/**/*(D-@); rm -iv -- ~/.local/**/*(D-@)

DOTFILE_DIR="$(cd "$(dirname ${0})" && pwd -P)" # absolute path to dir

# load env vars, including XDG_*
source "$DOTFILE_DIR/.zshenv"

# Ensure Zsh directories exist.
() {
  local zdir
  for zdir in $@; do
    [[ -d "${(P)zdir}" ]] || \mkdir -p -- "${(P)zdir}"
  done
} __zsh_{user_data,cache}_dir XDG_{CACHE,CONFIG,DATA,STATE}_HOME USER_{BIN,SHARE}


# obtain the absolute path of a file/dir
function realpath {
  local filename="$1"
  local parentdir=$(dirname "${filename}")

  if [ -d "${filename}" ]; then
    echo "$(cd "${filename}" && pwd -P)"
  elif [ -d "${parentdir}" ]; then
    echo "$(cd "${parentdir}" && pwd -P)/$(basename "$1")"
  fi
}

OS="$(uname -s | tr '[:lower:]' '[:upper:]')"

# make archive dir if doesn't exist
ARCHIVE_DIR="${DOTFILE_DIR}/old"
mkdir -p "$ARCHIVE_DIR"


# simple logging functions for printing output to stderr
function debug {
    local BLUE=$(tput setaf 4)
    local CLEAR=$(tput sgr0)
    echo "${BLUE}[*] $@${CLEAR}" >&2
}

function warn {
    local YELLOW=$(tput setaf 3)
    local CLEAR=$(tput sgr0)
    echo "${YELLOW}[!] $@${CLEAR}" >&2
}

function error {
    local RED=$(tput setaf 1)
    local CLEAR=$(tput sgr0)
    echo "${RED}[x] $@${CLEAR}" >&2
}

function success {
    local GREEN=$(tput setaf 2)
    local CLEAR=$(tput sgr0)
    echo "${GREEN}[+] $@${CLEAR}" >&2
}


# backs up old dotfile and replaces it with symlink to one here.
# Usage: install_dotfile FILE [DEST]
#  FILE - the dotfile in this directory that you want to install
#  DEST - optional override of destination where dotfile will go. Defaults to home dir.
function install_dotfile {
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
function install_ohmyzsh {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    debug "Installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  install_omz_extras() {
    local githubpath="https://github.com/$1"
    local item="$(basename $1)"  # get repo name
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

function install_tmux_plugin_mgr {
  if [[ ! -d "$XDG_CONFIG_HOME/tmux/plugins/tpm" ]]; then
    debug "Installing tmux plugin manager"
    git clone https://github.com/tmux-plugins/tpm "$XDG_CONFIG_HOME/tmux/plugins/tpm" \
        && "$XDG_CONFIG_HOME/tmux/plugins/tpm/bin/install_plugins"
  fi
}

# tools to make terminal nice
install_ohmyzsh
install_tmux_plugin_mgr

COMMON_DOTFILES=(
  .bash_aliases
  .config/alacritty
  .config/git
  .config/nvim
  .config/tmux/tmux.conf
  .config/wezterm
  .config/zsh
  .gdbinit
  .local/bin/static-get
  .local/share/fonts
  .vimrc
  .zshenv
)

# install common dotfiles
for df in "${COMMON_DOTFILES[@]}"; do
  install_dotfile "$df"
done

MAC_DOTFILES=()

# install MacOS-specific dotfiles
if [[ "$OS" == "DARWIN" ]]; then
  for df in "${MAC_DOTFILES[@]}"; do
    install_dotfile "$df"
  done

  # these require custom destinations, so can't use array (bash doesn't support 2D arrays)
  install_dotfile ".config/git/config-credential-mac" ".config/git/config-credential"
  install_dotfile .config/vscode/settings.json "$HOME/Library/Application Support/VSCodium/User/settings.json"
  install_dotfile .config/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
  install_dotfile .config/hatch/config.toml "$HOME/Library/Application Support/hatch/config.toml"
fi

LINUX_DOTFILES=(
  .canrc
  .config/terminator/config
  .config/vscode/settings.json
  .config/hatch/config.toml
  .snmp
)

KALI_DOTFILES=(
  .config/xfce4/helpers.rc
  .config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
  .config/xfce4/panel/whiskermenu-1.rc
  .config/AutoRecon
  .mozilla/firefox/addons.json
  .mozilla/firefox/installs.ini
  .mozilla/firefox/profiles.ini
  .mozilla/firefox/user.js
  .mozilla/firefox/extensions/{60f82f00-9ad5-4de5-b31c-b16a47c51558}.xpi
  .mozilla/firefox/extensions/foxyproxy@eric.h.jung.xpi
  .mozilla/firefox/e4vtk5tb.default-esr/bookmarkbackups
)

# install Linux-specific dotfiles
if [[ "$OS" == "LINUX" ]]; then
  for df in "${LINUX_DOTFILES[@]}"; do
    install_dotfile "$df"
  done

  install_dotfile ".config/git/config-credential-linux" ".config/git/config-credential"

  if [[ ! -d "$HOME/.ssh" ]]; then
    mkdir "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
  fi

  if [[ ! -f "$HOME/.ssh/config" ]]; then
    cp .ssh/config "$HOME/.ssh/config"
  fi

  DISTRO="$(grep ^ID /etc/os-release | cut -d= -f2 | tr '[:lower:]' '[:upper:]')"

  if [[ "$DISTRO" == "KALI" ]]; then
    for df in "${KALI_DOTFILES[@]}"; do
      install_dotfile "$df"
    done
  fi
fi

success DONE!

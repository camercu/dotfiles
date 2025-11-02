#########################################################################
##   Custom Shell Aliases and Functions   ###############################
#########################################################################

XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

#
###  Functions
#

##? current-shell: get name of current shell executable
function current-shell {
  basename "$(ps -o command= -p $$ | cut -d' ' -f1 | sed 's/^-//')"
}

# Shell checks - return true if current shell is zsh/bash
function is-zsh { ! (\builtin shopt) &>/dev/null && [ "${ZSH_VERSION+x}" ]; }
function is-bash { (\builtin shopt) &>/dev/null && [ "${BASH_VERSINFO+x}" ]; }

# OS checks
function is-macos { [[ "$OSTYPE" == darwin* ]]; }
function is-linux { [[ "$OSTYPE" == linux* ]]; }
function is-bsd { [[ "$OSTYPE" == *bsd* ]]; }
function is-solaris { [[ "$OSTYPE" == solaris* ]]; }
function is-windows { [[ "$OSTYPE" == cygwin* || "$OSTYPE" == msys ]]; }

##? is-installed: return true if command binary is installed on PATH
function is-installed { hash -- "$1" 2>/dev/null; }

# return true if function is defined
function is-function { declare -f -- "$1" &>/dev/null; }

# Absolute path to file (does not resolve symlinks)
! is-installed abspath &&
  function abspath {
    python3 -c "import os,sys; print(os.path.abspath(sys.argv[1]))" "$1"
  }
# Real (canonical) path to file (resolves symlinks)
! is-installed realpath &&
  function realpath {
    python3 -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$1"
  }

#
# Logging Functions - colorized printing of log messages
#
function debug {
  local -r BLUE=$(tput setaf 4)
  local -r CLEAR=$(tput sgr0)
  echo "${BLUE}[*] $*${CLEAR}" >&2
}

function warn {
  local -r YELLOW=$(tput setaf 3)
  local -r CLEAR=$(tput sgr0)
  echo "${YELLOW}[!] $*${CLEAR}" >&2
}

function error {
  local -r RED=$(tput setaf 1)
  local -r CLEAR=$(tput sgr0)
  echo "${RED}[x] $*${CLEAR}" >&2
}

function success {
  local -r GREEN=$(tput setaf 2)
  local -r CLEAR=$(tput sgr0)
  echo "${GREEN}[+] $*${CLEAR}" >&2
}

##? md: shortcut to make a directory and cd into it
function md {
  [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" && pwd
}

## (MacOS) Change directory to the top-most Finder window location
function cdf {
  is-macos &&
    cd "$(osascript -e '
            tell app "Finder" to POSIX path of (insertion location as alias)
            ')" || return
}

#
#
####  Aliases  ###########
#
#

## single character shortcuts - be sparing!
alias g=git
alias v=nvim

## neovim distros
alias lazyvim="NVIM_APPNAME=lazyvim nvim"
alias lunarvim="NVIM_APPNAME=lunarvim nvim"
alias nvchad="NVIM_APPNAME=nvchad nvim"
alias astronvim="NVIM_APPNAME=astronvim nvim"

## mask built-ins with better defaults
if is-installed vim; then
  alias vi=vim
fi

## easy dotfile editing commands
DOTFILE_EDITOR=$(hash nvim 2>/dev/null && echo nvim || echo vim)
case "$(current-shell)" in
zsh) alias erc="$DOTFILE_EDITOR \$ZDOTDIR/.zshrc --cmd 'cd \$ZDOTDIR'" ;;
bash) alias erc="$DOTFILE_EDITOR ~/.bashrc" ;;
*) ;;
esac
# Edit (Neo)Vim Config
alias ev="$DOTFILE_EDITOR --cmd 'cd ~/.config/nvim'"
alias ea="$DOTFILE_EDITOR ~/.bash_aliases --cmd 'cd ~/.dotfiles'"
unset DOTFILE_EDITOR
alias reload='exec $SHELL'
alias cdot='cd ~/.dotfiles'
alias zdot='cd $ZDOTDIR'
alias dotfiledir='dirname $(dirname $(realpath ~/.zshenv))'

## ls aliases
if is-installed lsd; then
  alias ls='lsd'
  alias tree='lsd --tree'
fi
alias l='ls'
alias la='ls -A'
alias ll='ls -Alh'
alias lt='ls -Alht'

## grep aliases
alias grep='grep --color=auto'
alias fgrep='grep -F'
alias egrep='grep -E'
alias rgrep='grep -r'

## cd aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....="cd ../../../.."
alias -- -="cd -"
alias cd..='cd ..' # typo fixer

## date/time
alias timestamp="date '+%Y-%m-%d %H:%M:%S'"
alias datestamp="date '+%Y-%m-%d'"
alias isodate="date +%Y-%m-%dT%H:%M:%S%z"
alias utc="date -u +%Y-%m-%dT%H:%M:%SZ"
alias unixepoch="date +%s"
alias now="date '+%Y%m%d%H%M%S'"

## tmux aliases
alias tmux="tmux -u" # force UTF-8
alias tk='tmux kill-session -t'
alias ta='tmux attach'
alias tl='tmux list-sessions'
alias ts='tmux new-session -s'

## encoding/decoding
alias rot13="python3 -c 'import sys, codecs;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read();print(codecs.encode(s,\"rot_13\"))'"
alias urlencode="python3 -c 'import sys,os,urllib.parse as url;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.buffer.read();print(url.quote_plus(os.fsencode(s)))'"
alias urldecode="python3 -c 'import sys,urllib.parse as url;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read();print(url.unquote(s.strip()))'"
alias b64encode="python3 -c 'import sys,os,base64 as b64;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.buffer.read();print(b64.b64encode(os.fsencode(s)).decode())'"
alias b64e='b64encode'
alias b64decode="python3 -c 'import sys,base64 as b;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read();sys.stdout.buffer.write(b.b64decode(s.strip()));'"
alias b64d='b64decode'
alias b16encode=$'python3 -c \'import sys,os,base64 as b16;s=" ".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.buffer.read();print(b16.b16encode(os.fsencode(s)).decode())\''
alias b16e='b16encode'
alias b16decode="python3 -c 'import sys, base64 as b;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read();sys.stdout.buffer.write(b.b16decode(s.strip().upper()));'"
alias b16d='b16decode'
# hex to decimal conversion (and visa-versa)
alias hex2dec="python3 -c 'import sys;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read();print(int(s.strip(),16));'"
alias h2d='hex2dec'
alias dec2hex="python3 -c 'import sys;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read();print(hex(int(s.strip())));'"
alias d2h='dec2hex'
# convert binary file to escaped shellcode string format (e.g. "\x90")
alias bin2sc=$'python3 -c \'import sys,os,textwrap as tw;s=" ".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read();[print(f"\\"{x}\\"") for x in tw.wrap("".join(f"\\\\x{b:02x}" for b in os.fsencode(s)),75)]\''
# generate NTLM hash of given password
alias ntlmhash=$'python3 -c \'import sys as s,hashlib as h;x=" ".join(s.argv[1:]) if len(s.argv)>1 else s.stdin.read();print(h.new("md4", x.encode("utf-16le")).hexdigest())\''

#
# clipboard: Use pbcopy/pbpaste (macOS) clipboard commands everywhere.
#
# source: https://github.com/mattmc3/zdotdir/blob/main/lib/clipboard.zsh
#
if ! is-installed pbcopy && ! is-installed pbpaste; then
  if [[ "$OSTYPE" == cygwin* ]]; then
    alias pbcopy='tee > /dev/clipboard'
    alias pbpaste='cat /dev/clipboard'
  elif [[ "$OSTYPE" == linux-android ]]; then
    alias pbcopy='termux-clipboard-set'
    alias pbpaste='termux-clipboard-get'
  elif is-installed wl-copy && is-installed wl-paste; then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
  elif [[ -n $DISPLAY ]]; then
    if is-installed xclip; then
      alias pbcopy='xclip -selection clipboard -in'
      alias pbpaste='xclip -selection clipboard -out'
    elif is-installed xsel; then
      alias pbcopy='xsel --clipboard --input'
      alias pbpaste='xsel --clipboard --output'
    fi
  fi
fi

#
# open: Use `open` (macOS) command everywhere.
#
# source: https://github.com/mathiasbynens/dotfiles/blob/main/.functions
if ! is-macos; then
  if grep -q Microsoft /proc/version; then
    # Ubuntu on Windows using the Linux subsystem
    alias open='explorer.exe'
  else
    alias open='xdg-open'
  fi
fi

# `o` with no arguments opens the current directory,
# otherwise opens the given location
function o() {
  if [ $# -eq 0 ]; then
    open .
  else
    open "$@"
  fi
}

###  miscellaneous  ###
alias df='df -H'
alias duff='diff -ur'
alias mkdir='mkdir -p'
alias remake='make -B'
alias su='su -'
alias path='echo $PATH | tr ":" "\n"'
alias fpath='echo $FPATH | tr ":" "\n"'
alias nsort='sort | uniq -c | sort -n'
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias 2b="cd ~/second-brain && $EDITOR"
is-installed lazygit && alias lg='lazygit'

# update all pip packages
alias pipup='pip freeze --local | grep -v "^\-e" | cut -d = -f 1  |xargs -n1 pip install -U'
alias pip3up='pip3 freeze --local | grep -v "^\-e" | cut -d = -f 1  | xargs -n1 pip3 install -U'
#
# list the size of directories in descending order
alias ducks='du -cks * | sort -rn | head -11'

# convert hex-escaped files (streams) to raw binary
alias hex2raw="tr -d '\\\x' | xxd -r -p"

# disable host-key verification and saving when running ssh
alias ssh-noverify='ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"'
alias sshnv=ssh-noverify

# Terminal Logging
alias startlog='script term-$(now).log'

#
#
# OS-specific Aliases
#
#

####   Mac Specific:   ##########
if is-macos; then
  alias brewup='brew update && brew upgrade && brew cleanup'
  alias brewinfo="brew leaves | xargs brew desc --eval-all"
  alias md5sum='openssl md5'
  alias sha1sum='openssl sha1'
  alias sha256sum='openssl sha256'
  alias is-admin='groups | grep -qw admin;'
  alias maintain='dotsync && make -C ~/.config/nix-darwin'

  # Show/Hide hidden files in Finder
  alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
  alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
fi

####   Linux Specific:  ##########
if is-linux; then
  # upgrade all packages
  alias maintain='sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y && sudo apt-get autoclean -y'

  alias arp='ip neigh'

  # colorize ip command output
  alias ip='ip -color=auto'

  # fd-find alias
  alias fd='fdfind'

  # set up can0 socketCAN interface
  # before running, add can, vcan, and can-isotp to /etc/modules
  # and also modprobe those modules
  alias canup='sudo ip link set up can0 txqueuelen 65535 type can bitrate 500000 \
        && ip a s can0'
  # create and configure vcan0 virtual CAN interface
  alias vcanup='sudo ip link add dev vcan0 type vcan \
        && sudo ip link set dev vcan0 up \
        && ip a s vcan0'

  DISTRO="$(grep ^ID /etc/os-release | cut -d= -f2 | tr '[:lower:]' '[:upper:]')"
  if [[ "$DISTRO" == "KALI" ]]; then
    # create a pattern with metasploit's pattern_create.rb
    alias pattcreat='/usr/share/metasploit-framework/tools/exploit/pattern_create.rb -l'
    alias pattoffs='/usr/share/metasploit-framework/tools/exploit/pattern_offset.rb -q'

    ## helpers for upgrading reverse shell
    alias fixpath='echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
    alias fixterm='echo "export TERM=xterm-256color"'

    # other
    alias cme='crackmapexec'
    alias ssploit='searchsploit'

    ##? newbox: initialize directory for new Hack-The-Box/OSCP/etc. machine
    function newbox {
      local name="$1"
      mkdir "$name"
      pushd -q "$name" || return
      mkdir scans pwn loot assets
      touch "$name.md"
      popd -q || return
    }

    ## If working in hacking vm  ############
    if [ -d "/mnt/share" ]; then
      alias cdshare='cd /mnt/share'
      alias cdcheat='cd /mnt/share/cheat'
      alias cdtools='cd /mnt/share/cheat/tools'

      ## openvpn
      alias thmconnect='sudo openvpn /mnt/share/thm/tryhackme-ccu337.ovpn'
      alias htbconnect='sudo openvpn /mnt/share/htb/lab_camercu.ovpn'
      alias pwkconnect='echo OS-80249; sudo openvpn /mnt/share/offsec/universal.ovpn'
      alias pgconnect='sudo openvpn /mnt/share/offsec/universal.ovpn'
    fi
  fi
  unset DISTRO
fi

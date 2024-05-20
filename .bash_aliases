#########################################################################
##    Custom Zsh Aliases   ##############################################
#########################################################################

# add simple logging (stderr) functions: debug, warn, error, success
# also adds 'now' function to get timestamp
[[ -f "$HOME/.logging.sh" ]] && source "$HOME/.logging.sh"

####  Variables  #########

# # REGEX's
# DOMAIN='(\w|-)+(\.[a-zA-Z]+)+\b'
# EMAIL="(\w|-|\.)+@$DOMAIN"
# OCTET='[012]{0,1}\d{1,2}'
# IP="($OCTET\.){3}$OCTET"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
DISTRO="$(grep ^ID /etc/os-release | cut -d= -f2 | tr '[:lower:]' '[:upper:]')"

####  Aliases  ###########

## ls aliases
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

# Easy navigation in zsh:
if [[ "$(basename "$(ps -o command= -p $$ | sed 's/^-//')")" == "zsh" ]]; then
  alias d='dirs -v | head -10'
  alias 1='cd -'
  alias 2='cd -2'
  alias 3='cd -3'
  alias 4='cd -4'
  alias 5='cd -5'
  alias 6='cd -6'
  alias 7='cd -7'
  alias 8='cd -8'
  alias 9='cd -9'
fi

## tmux aliases
alias tmux="tmux -u"
alias tk='tmux kill-session -t'
alias ta='tmux a'
alias tl='tmux list-sessions'
alias ts='tmux new-session -s'

## encoding/decoding
alias rot13="python3 -c 'import sys, codecs;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read().encode();print(codecs.encode(s,\"rot_13\"))'"
alias urlencode="python3 -c 'import sys,os,urllib.parse as url;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read().encode();print(url.quote_plus(os.fsencode(s)))'"
alias urldecode="python3 -c 'import sys,urllib.parse as url;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read().encode();print(url.unquote(s.strip()))'"
alias b64encode="python3 -c 'import sys,os,base64 as b64;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read().encode();print(b64.b64encode(os.fsencode(s)).decode())'"
alias b64e='b64encode'
alias b64decode="python3 -c 'import sys,base64 as b;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read().encode();sys.stdout.buffer.write(b.b64decode(s.strip()));'"
alias b64d='b64decode'
alias b16encode=$'python3 -c \'import sys,os,base64 as b16;s=" ".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read().encode();print(b16.b16encode(os.fsencode(s)).decode())\''
alias b16e='b16encode'
alias b16decode="python3 -c 'import sys, base64 as b;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read().encode();sys.stdout.buffer.write(b.b16decode(s.strip().upper()));'"
alias b16d='b16decode'
# hex to decimal conversion (and visa-versa)
alias hex2dec="python3 -c 'import sys;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read().encode();print(int(s.strip(),16));'"
alias h2d='hex2dec'
alias dec2hex="python3 -c 'import sys;s=\" \".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read().encode();print(hex(int(s.strip())));'"
alias d2h='dec2hex'
# convert binary file to escaped shellcode string format (e.g. "\x90")
alias bin2sc=$'python3 -c \'import sys,os,textwrap as tw;s=" ".join(sys.argv[1:]) if len(sys.argv)>1 else sys.stdin.read();[print(f"\\"{x}\\"") for x in tw.wrap("".join(f"\\\\x{b:02x}" for b in os.fsencode(s)),75)]\''
# generate NTLM hash of given password
alias ntlmhash=$'python3 -c \'import sys as s,hashlib as h;x=" ".join(s.argv[1:]) if len(s.argv)>1 else s.stdin.read().encode();print(h.new("md4", x.encode("utf-16le")).hexdigest())\''

###  miscellaneous  ###
alias df='df -H'
alias duff='diff -ur'
alias mkdir='mkdir -p'
alias remake='make -B'
alias su='su -'
alias path='echo $PATH'
alias nsort='sort | uniq -c | sort -n'
alias pysrv='python3 -m http.server'
alias v='nvim'

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

## easy dotfile editing commands
DOTFILE_EDITOR=vim
case "$(basename "$(ps -o command= -p $$ | sed 's/^-//')")" in
  zsh) alias erc="$DOTFILE_EDITOR ~/.zshrc";;
  bash) alias erc="$DOTFILE_EDITOR ~/.bashrc";;
  *) ;;
esac
alias ea="$DOTFILE_EDITOR ~/.bash_aliases"
unset DOTFILE_EDITOR
alias reload="exec $SHELL"
alias cdot='cd ~/.dotfiles'


####   Mac Specific:   ##########
if [[ "$OS" == "darwin" ]]; then
    alias brewup='brew update && brew upgrade && brew cleanup'
    alias md5sum='openssl md5'
    alias sha1sum='openssl sha1'
    alias sha256sum='openssl sha256'
fi


####   Linux Specific:  ##########
if [[ "$OS" == "linux" ]]; then
    # upgrade all packages
    alias maintain='sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y && sudo apt-get autoclean -y'

    alias arp='ip neigh'

    # copy to clipboard
    alias clip='xclip -sel clip'

    # colorize ip command output
    alias ip='ip -color=auto'

    # fd-find alias
    alias fd='fdfind'

    # display tun0 ip addr
    alias vpnip="ip a s tun0 | grep -w inet | awk '{print \$2}' | cut -d '/' -f 1"
    # export VPNIP=$(ip -f inet addr show tun0 | grep -Po 'inet \\K\[\\d.\]+')

    # set up can0 socketCAN interface
    # before running, add can, vcan, and can-isotp to /etc/modules
    # and also modprobe those modules
    alias canup='sudo ip link set up can0 txqueuelen 65535 type can bitrate 500000 \
        && ip a s can0'
    # create and configure vcan0 virtual CAN interface
    alias vcanup='sudo ip link add dev vcan0 type vcan \
        && sudo ip link set dev vcan0 up \
        && ip a s vcan0'

    # grep through ps and netstat listings:
    alias psg='ps -ef ww | grep -i $1'
    alias nsg='netstat -natp | grep -i $1'

    if [[ "$DISTRO" == "kali" ]]; then
        # create a pattern with metasploit's pattern_create.rb
        alias pattcreat='/usr/share/metasploit-framework/tools/exploit/pattern_create.rb -l'
        alias pattoffs='/usr/share/metasploit-framework/tools/exploit/pattern_offset.rb -q'

        # other
        alias cme='crackmapexec'
        alias ssploit='searchsploit'

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

            ## helpers for upgrading reverse shell
            alias fixpath='echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
            alias fixterm='echo "export TERM=xterm-256color"'
        fi
    fi
fi

########################################################################
###  Functions     #####################################################
########################################################################

# Shortcut to make a directory and cd into it
function mcd {
    mkdir -p $1 && cd $1 && pwd
}

# start new box
function newbox {
    local name="$1"
    mkdir "$name"
    pushd -q "$name"
    mkdir scans pwn loot assets
    touch "$name.md"
    popd -q
}

# history-delete: delete a line (offset) from your shell history
# source: https://stackoverflow.com/a/63494771/5202294
function hd {
    # Usage: hd START [STOP]
    # where START and STOP are history line numbers.
    # Alternatively, you can do `hd -1` to remove the last line.
    START=${1}
    STOP=${2:-$START}

    # Prevent the specified history line from being saved.
    local HISTORY_IGNORE="${(b)$(fc -ln $START $STOP)}"
    # Write history to file, excluding lines matching `$HISTORY_IGNORE`
    fc -W
    # Dispose of current history and read new history from file.
    fc -p $HISTFILE $HISTSIZE $SAVEHIST
    print "Deleted '$HISTORY_IGNORE' from history."
}

# overrides builtin zshaddhistory to prevent logging `hd` commands
function zshaddhistory {
    [[ $1 != 'hd '* ]]
}

# fuzzy-search hashcat modes
# source: https://jonathanh.co.uk/blog/fuzzy-search-hashcat-modes.html
# NOTE: fzf and hashcat required to be installed
function hcmode {
    hashcat --example-hashes | grep -E 'MODE:|TYPE:|HASH:|Hash mode #|Name\.*:|Example\.Hash\.*:|^$' | awk -v RS="\n\n" -F "\t" '{gsub("\n","\t",$0); print $1 "\t" $2 "\t" $3}' | sed 's/MODE: //; s/Hash mode #//; s/TYPE: //; s/ *Name\.*: //; s/Example\.Hash\.*://; s/HASH: //' | fzf -d '\t' --header="Mode   Type" --preview='echo HASH: {3}' --preview-window=up:1 --reverse --height=40% | awk '{print $1}'
}

# add a pubkey to ssh authorized keys for port fwd only
function ptfwd-add {
    if [ $# -ne 2 ]; then
        echo "Usage: ptfwd-add  FROM_ADDR  SSH_PUBKEY_TEXT"
        return 1
    fi
    local from_addr=$1
    local pubkey=$2
    echo "from=\"$from_addr\",command=\"echo 'This account can only be used for port forwarding'\",no-agent-forwarding,no-X11-forwarding,no-pty $pubkey" >> ~/.ssh/authorized_keys
}

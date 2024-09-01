#!/usr/bin/env zsh

#
# Tab Completions
#

#
# Options
#
# https://zsh.sourceforge.io/Doc/Release/Options.html#Completion-4

unsetopt MENU_COMPLETE      # Do not autoselect the first completion entry
unsetopt FLOWCONTROL        # Disable output flow control via start/stop chars (usually ^S/^Q)
setopt ALWAYS_TO_END        # Move cursor to end of completion suggestion.
setopt AUTO_MENU            # Show completion menu on successive tab press
setopt COMPLETE_IN_WORD     # cursor stays put, completion from both ends

#
# Matcher Options
#

zstyle ':completion:*:*:*:*:*' menu select

# try case insensitive, allow partial completion before ._-,
# allow partial completion from end of word
# to prefer exact match first, add `''` after matcher-list
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# complete . and .. special directories
zstyle ':completion:*' special-dirs true

# colorize completions for `kill`
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# how to complete processes
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

#
# Initialize completions
#

# give bindkey access to 'menuselect'
zmodload -i zsh/complist

# initialize completions with caching
autoload -U compinit && compinit -u -d "$ZSH_COMPDUMP"
autoload -U +X bashcompinit && bashcompinit

# 'md' function: complete directories
if is-function md; then
    compdef _directories md
fi

# terraform completions
complete -o nospace -C /usr/local/bin/terraform terraform


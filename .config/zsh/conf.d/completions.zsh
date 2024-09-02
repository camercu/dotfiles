#!/usr/bin/env zsh

#
# Tab Completions
#

# give bindkey access to 'menuselect', must be called before compinit
zmodload zsh/complist


#
# Options
#
# https://zsh.sourceforge.io/Doc/Release/Options.html#Completion-4

setopt ALWAYS_TO_END        # Move cursor to end of completion suggestion.
setopt AUTO_LIST            # Automatically list choices on ambiguous completion
setopt AUTO_MENU            # Show completion menu on successive tab press
setopt COMPLETE_IN_WORD     # cursor stays put, completion from both ends
unsetopt FLOWCONTROL        # Disable output flow control via start/stop chars (usually ^S/^Q)
unsetopt MENU_COMPLETE      # Do not autoselect the first completion entry

#
# Matcher Options
#

# completers
zstyle ':completion:*' completer _extensions _complete _approximate

# use select-style menu to pick completion
zstyle ':completion:*:*:*:*:*' menu select search

# autocomplete options instead of directory stack
zstyle ':completion:*' complete-options true

# sort files by modification datetime instead of alphabetically
zstyle ':completion:*' file-sort modification

# try case insensitive, allow partial completion before ._-,
# allow partial completion from end of word
# to prefer exact match first, add `''` after matcher-list
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# complete . and .. special directories
zstyle ':completion:*' special-dirs true

# formatted labels on groups in completion menu
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
# zstyle ':completion:*:default' list-prompt '%S%M matches%s'

# Colors for files and directories
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}
# zstyle ':completion:*' list-colors ''

# colors for `kill` processes
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# autocomplete processes using `ps` output
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"

# disable named-directories autocompletion for cd
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# group completions by tag
zstyle ':completion:*' group-name ''

# ordering of groups for command completion
zstyle ':completion:*:*:-command-:*:*' group-order aliases functions builtins commands

# don't auto-expand tilde to home-directory
zstyle ':completion:*' keep-prefix true

# populate known_hosts for autocompletion in ssh, etc.
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

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

# completions can include hidden files
# _comp_options+=(globdots)


#
# Initialize completions
#

# initialize completions with caching
autoload -U compinit && compinit -u -d "$ZSH_COMPDUMP"
autoload -U +X bashcompinit && bashcompinit

# 'md' function: completes with directories
if is-function md; then
    compdef _directories md
fi


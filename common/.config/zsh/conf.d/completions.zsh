#!/usr/bin/env zsh

#
# Tab Completions
#

# give bindkey access to 'menuselect'
# must be called before compinit or setting menuselect keybindings
zmodload -i zsh/complist


#
# Options
#
# https://zsh.sourceforge.io/Doc/Release/Options.html#Completion-4
# man zshoptions - Search for "Completion"

setopt ALWAYS_TO_END        # Move cursor to end of completion suggestion.
setopt AUTO_LIST            # Automatically list choices on ambiguous completion
setopt AUTO_MENU            # Show completion menu on successive tab press
setopt COMPLETE_IN_WORD     # cursor stays put, completion from both ends
setopt MENU_COMPLETE        # Autoselect the first completion entry
unsetopt FLOWCONTROL        # Disable output flow control via start/stop chars (usually ^S/^Q)

# completions can include hidden files
_comp_options+=(globdots)



#
# Matcher Options
#
# man zshmodules - Search for "zstyle"
# man zshcompsys - Search for "Standard Styles"
# man zshcompsys - Search for "Standard Tags"
# http://www.fifi.org/doc/zsh-doc/html/zsh_19.html
#
# zstyle template:
# :completion:<function>:<completer>:<command>:<argument>:<tag>

# completers
zstyle ':completion:*' completer _extensions _complete _approximate

# use select-style menu to pick completion
zstyle ':completion:*:*:*:*:*' menu select

# autocomplete options instead of directory stack when doing hyphen-TAB
zstyle ':completion:*' complete-options true

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# sort files by modification datetime instead of alphabetically
zstyle ':completion:*' file-sort modification follow

# Use caching so that commands like apt and dpkg complete are usable
zstyle ':completion:*' use-cache yes

# prefer exact match first (`''` after matcher-list),
# try case & hyphen/underscore insensitive,
# allow partial completion before ._-,
# allow partial completion from end of word
# man zshcompwid - Search for "COMPLETION MATCHING CONTROL"
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# formatted labels on groups in completion menu
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
# zstyle ':completion:*:default' list-prompt '%S%M matches%s'

# autocomplete processes using `ps` output
if [[ "$OSTYPE" = solaris* ]]; then
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm"
else
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
fi

# disable named-directories autocompletion for cd
zstyle ':completion:*:cd:*' tag-order 'local-directories directory-stack path-directories'

# group completions by tag
zstyle ':completion:*' group-name ''

# ordering of groups for command completion
zstyle ':completion:*:*:-command-:*:*' group-order aliases functions commands builtins

# don't treat multiple slashes as glob directory path
zstyle ':completion:*' squeeze-slashes true

# don't auto-expand tilde to home-directory
zstyle ':completion:*' keep-prefix true

# populate known_hosts for autocompletion in ssh, etc.
zstyle -e ':completion:*:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

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

# Show dots when waiting for completion
export COMPLETION_WAITING_DOTS=true
expand-or-complete-with-dots() {
  # use $COMPLETION_WAITING_DOTS either as toggle or as the sequence to show
  [[ $COMPLETION_WAITING_DOTS = true ]] && COMPLETION_WAITING_DOTS="%F{red}…%f"
  # turn off line wrapping and print prompt-expanded "dot" sequence
  printf '\e[?7l%s\e[?7h' "${(%)COMPLETION_WAITING_DOTS}"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
# Set the function as the default tab completion widget
bindkey -M emacs "^I" expand-or-complete-with-dots
bindkey -M viins "^I" expand-or-complete-with-dots
bindkey -M vicmd "^I" expand-or-complete-with-dots


#
# Colors
#
# man zshmodules - Search "Colored completion listings"

# Colors for files and directories
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}
# zstyle ':completion:*' list-colors ''

# colors for `kill` processes
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'



#
# Complist Menu keybindings
#
# man zshmodules - Search for “THE ZSH/COMPLIST MODULE”

bindkey -M menuselect '^[' send-break                               # [Esc] Exit menu and restore
bindkey -M menuselect '^M' accept-line                              # [Enter] accept suggest history
bindkey -M menuselect '^[^M' .accept-line                           # [Alt-Enter] accept and execute
bindkey -M menuselect '^xg' clear-screen                            # [Ctrl-x g] Clear screen
bindkey -M menuselect '^xi' vi-insert                               # [Ctrl-x i] Insert
bindkey -M menuselect '^xh' accept-and-hold                         # [Ctrl-x h] Hold
bindkey -M menuselect '^xn' accept-and-infer-next-history           # [Ctrl-x n] Next (accept and keep completing)
bindkey -M menuselect '^xu' undo                                    # [Ctrl-x u] Undo
bindkey -M menuselect '^r' history-incremental-search-forward       # [Ctrl-r] next history search result
bindkey -M menuselect '^R' history-incremental-search-forward       # [Ctrl-R] prev history search result


#
# Custom Completions
#

# Load personal completion functions onto fpath
fpath+="${ZDOTDIR}/completions"

# 'md' function: completes with directories
if is-function md; then
  compdef _directories md
fi

# 'd' function: complete with directories
if is-function d; then
  compdef _directories d
fi

# Enable tab completion for `g` by marking it as an alias for `git`
if (( $+functions[_git] )) && alias g &> /dev/null; then
  compdef _git g=git
fi

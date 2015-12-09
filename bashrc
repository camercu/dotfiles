##################################
# Personal aliases and functions.
##################################

# Personal environment variables and startup programs should go in
# ~/.bash_profile.  System wide environment variables and startup
# programs are in /etc/profile.  System wide aliases and functions are
# in /etc/bashrc.

# include global bashrc settings
if [ -e '/etc/bashrc' ] ; then
  source /etc/bashrc
fi



######################
# Alias definitions.
######################
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

alias bashreload='. ~/.bash_profile' # same as 'source ~/.bash_profile'
alias bpe='edit ~/.bash_profile'
alias brce='edit ~/.bashrc'
alias brewup='brew update && brew upgrade && brew cleanup && brew cask cleanup'
alias df='df -h'
alias duff='diff -ur'
alias gdb='gdb -q'
alias git='hub'
alias gitca='git add . && git commit'
alias gitinit='git init && git add . && git commit -m "initial commit"'
alias gitsync='git checkout master && git fetch upstream && git merge upstream/master'
alias md5sum='openssl md5'
alias mkdir='mkdir -p'
alias pipup='pip freeze --local | grep -v "^\-e" | cut -d = -f 1  | xargs -n1 sudo -H pip install -U'
alias remake='make -B'
alias sha1sum='openssl sha1'
alias su='su -'

# list the size of directories in descending order
alias ducks='du -cks * | sort -rn | head -11'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -Ah' # --color=auto not used because of settings in bash_profile
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    # alias grep='grep --color=auto' # already in bash_profile
    alias fgrep='grep -F'
    alias egrep='grep -E'
    alias rgrep='grep -r'
fi

# some more ls aliases
alias lsl='ls -Ahl'
alias l='ls -CF'
alias ll='lsl -T'

## some useful aliases, so new users don't hurt themselves
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
# alias ls='ls -F'


# global pip installation
#gpip(){
#   PIP_REQUIRE_VIRTUALENV="" pip "$@"
#}

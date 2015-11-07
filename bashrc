##################################
# Personal aliases and functions.
##################################

# Personal environment variables and startup programs should go in
# ~/.bash_profile.  System wide environment variables and startup
# programs are in /etc/profile.  System wide aliases and functions are
# in /etc/bashrc.


alias bashreload=". ~/.bash_profile" # same as "source ~/.bash_profile"
alias bpe='edit ~/.bash_profile'
alias brce='edit ~/.bashrc'
alias brewup='brew update && brew upgrade && brew cleanup && brew cask cleanup'
alias df='df -h'
alias duff='diff -ur'
alias gitca='git add . && git commit'
alias gitinit='git init && git add . && git commit -m "initial commit"'
alias gitsync='git checkout master && git fetch upstream && git merge upstream/master'
alias grep='grep -r --color=auto'
alias ls='ls -a'
alias lsl="ls -l"
alias md5sum='openssl md5'
alias mkdir='mkdir -p'
alias pipup='pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip install -U'
alias remake='make -B'
alias sha1sum='openssl sha1'
alias su='su -'

# list the size of directories in descending order
alias ducks='du -cks * | sort -rn | head -11'

## some useful aliases, so new users don't hurt themselves
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
# alias ls='ls -F'

# set up the editor for programs that want them
export EDITOR='nano'
export VISUAL='nano'

# Ensure history appends to disk (rather than overwrite, when multi windows open).
shopt -s histappend
PROMPT_COMMAND='history -a'

# save multiline commands as one command
shopt -s cmdhist

# No duplicate entries in history. Also ignore (don't put in history)
# duplicate commands and commands preceded by a space (useful if you don't 
# want a command recorded in your history
export HISTCONTROL="erasedups:ignoreboth"

# Big(ish) history file
export HISTSIZE=1000
export HISTFILE = ~/.bash_history

# ensure history expansion is on (might make "!" try to expand undesirably)
# set -o histexpand

# have bash display expanded history commands before executing (paranoid)
# shopt -s histverify # redundant with magic-space

# don't put 'exit' command in history
# can string commands together with "cmd1:cmd2"
# wildcard "*" also ok
export HISTIGNORE="exit"

# small typos ignored in directory names
shopt -s cdspell

# global pip installation
#gpip(){
#   PIP_REQUIRE_VIRTUALENV="" pip "$@"
#}

# include global bashrc settings
if [ -f "/etc/bashrc" ] ; then
  source /etc/bashrc
fi
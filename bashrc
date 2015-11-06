##################################
# Personal aliases and functions.
##################################

# Personal environment variables and startup programs should go in
# ~/.bash_profile.  System wide environment variables and startup
# programs are in /etc/profile.  System wide aliases and functions are
# in /etc/bashrc.


alias ls='ls -a'
alias lsl="ls -l"
alias df='df -h'
alias gitinit='git init && git add . && git commit -m "initial commit"'
alias gitca='git add . && git commit'
alias gitsync='git checkout master && git fetch upstream && git merge upstream/master'
alias grep='grep --color=auto'
alias brewup='brew update && brew upgrade && brew cleanup && brew cask cleanup'
alias bpe='edit ~/.bash_profile'
alias brce='edit ~/.bashrc'
alias su='su -'
alias remake='make -B'
alias md5sum='openssl md5'
alias sha1sum='openssl sha1'
alias pipup='pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip install -U'
alias bashreload=". ~/.bash_profile" # same as "source ~/.bash_profile"

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

# global pip installation
#gpip(){
#   PIP_REQUIRE_VIRTUALENV="" pip "$@"
#}

# include global bashrc settings
if [ -f "/etc/bashrc" ] ; then
  source /etc/bashrc
fi
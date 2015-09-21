# Custom Aliases
alias ls='ls -a'
alias lsl="ls -l"
alias df='df -h'
alias gitinit='git init && git add . && git commit -m "initial commit"'
alias gitca='git add . && git commit'
alias gitsync='git checkout master && git fetch upstream && git merge upstream/master'
alias brewup='brew update && brew upgrade && brew cleanup && brew cask cleanup'
alias bpe='edit ~/.bash_profile'
alias brce='edit ~/.bashrc'
alias su='su -'
alias remake='make -B'
alias md5sum='openssl md5'
alias sha1sum='openssl sha1'
alias pipup='pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip install -U'

# Master Password Name
export MP_FULLNAME="Cameron Charles Unterberger"

# global pip installation
#gpip(){
#   PIP_REQUIRE_VIRTUALENV="" pip "$@"
#}

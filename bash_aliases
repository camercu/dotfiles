alias bashreload='. ~/.bash_profile' # same as 'source ~/.bash_profile'
alias df='df -H'
alias duff='diff -ur'
alias mkdir='mkdir -p'
alias remake='make -B'
alias su='su -'

## Mac Specific:
alias brewup='brew update && brew upgrade && brew cleanup && brew cask cleanup'
alias cdot='cd ~/.dotfiles'
alias md5sum='openssl md5'
alias sha1sum='openssl sha1'
alias sha256sum='openssl sha256'
alias pipup='pip freeze --local | grep -v "^\-e" | cut -d = -f 1  |xargs -n1 sudo -H pip install -U'
alias pip3up='pip3 freeze --local | grep -v "^\-e" | cut -d = -f 1  | xargs -n1 sudo -H pip3 install -U'

# list the size of directories in descending order
alias ducks='du -cks * | sort -rn | head -11'

# convert hex-escaped files (streams) to raw binary
alias hex2raw="tr -d '\\\x' | xxd -r -p"

## enable color support
alias dircolors='gdircolors'
if [ -n "$(which dircolors)" ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

## dir coloring
[ -n "$(which dir)" ] && alias dir='dir --color=auto'
[ -n "$(which vdir)" ] && alias vdir='vdir --color=auto'

## ls aliases
alias ls='ls -A'
alias lsl='ls -hlT'
alias ll='lsl'

## grep aliases
alias grep='grep --color=auto'
alias fgrep='grep -F'
alias egrep='grep -E'
alias rgrep='grep -r'

## cd aliases
alias ..='cd ..'
alias ...='cd ../..'

## git aliases
alias gitca='git commit -a'
alias gitinit='git init && git commit -a -m "initial commit"'
alias gitsync='git checkout master && git fetch upstream && git merge upstream/master'

## set easy dotfile editing commands
if [ -n "$(which edit)" -a "$(logname)" = "$(whoami)" ]; then
	DOTFILE_EDITOR=edit
else
	DOTFILE_EDITOR=nano
fi
alias bpe="$DOTFILE_EDITOR ~/.bash_profile"
alias brce="$DOTFILE_EDITOR ~/.bashrc"
alias bae="$DOTFILE_EDITOR ~/.bash_aliases"
alias irce="$DOTFILE_EDITOR ~/.inputrc"
unset DOTFILE_EDITOR

## some useful aliases, so new users don't hurt themselves
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
# alias ls='ls -F'

##################################
# Personal aliases and functions
##################################

# Personal environment variables and startup programs should go in
# ~/.bash_profile.  System wide environment variables and startup
# programs are in /etc/profile.  System wide aliases and functions are
# in /etc/bashrc.

# include global bashrc settings
if [ -f '/etc/bashrc' ] ; then
  source /etc/bashrc
fi



######################
# Alias definitions
######################
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# set easy dotfile editing commands
if [ -n "$(which edit)" -a "$(logname)" = "$(whoami)" ]; then
	DOTFILE_EDITOR=edit
else
	DOTFILE_EDITOR=nano
fi
alias bpe="$DOTFILE_EDITOR ~/.bash_profile"
alias brce="$DOTFILE_EDITOR ~/.bashrc"
alias irce="$DOTFILE_EDITOR ~/.inputrc"
unset DOTFILE_EDITOR

alias ..='cd ..'
alias ...='cd ../..'
alias bashreload='. ~/.bash_profile' # same as 'source ~/.bash_profile'
alias brewup='brew update && brew upgrade && brew cleanup && brew cask cleanup'
alias cdot='cd ~/.dotfiles'
alias df='df -H'
alias dircolors='gdircolors'
alias duff='diff -ur'
alias gitca='git commit -a'
alias gitinit='git init && git commit -a -m "initial commit"'
alias gitsync='git checkout master && git fetch upstream && git merge upstream/master'
alias md5sum='openssl md5'
alias mkdir='mkdir -p'
alias pipup='pip freeze --local | grep -v "^\-e" | cut -d = -f 1  | xargs -n1 sudo -H pip install -U'
alias remake='make -B'
alias sha1sum='openssl sha1'
alias su='su -'

# list the size of directories in descending order
alias ducks='du -cks * | sort -rn | head -11'

# convert hex-escaped files (streams) to raw binary
alias hex2raw="tr -d '\\\x' | xxd -r -p"

# enable color support
if [ -n "$(which dircolors)" ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# ls aliases
alias ls='ls -A'  # --color=auto not used because already set in bash_profile
alias lsl='ls -hlT'
alias ll='lsl'

# dir coloring
[ -n "$(which dir)" ] && alias dir='dir --color=auto'
[ -n "$(which vdir)" ] && alias vdir='vdir --color=auto'

# grep aliases
# alias grep='grep --color=auto' # already in bash_profile
alias fgrep='grep -F'
alias egrep='grep -E'
alias rgrep='grep -r'

## some useful aliases, so new users don't hurt themselves
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
# alias ls='ls -F'


########################
# Function definitions
########################
function update_terminal_cwd {
    # Identify the directory using a "file:" scheme URL,
    # including the host name to disambiguate local vs.
    # remote connections. Percent-escape spaces.
    local SEARCH=' '
    local REPLACE='%20'
    local PWD_URL="file://$HOSTNAME${PWD//$SEARCH/$REPLACE}"
    printf '\e]7;%s\a' "$PWD_URL"
}


function extract {
	if [ -z "$1" ]; then
		# display usage if no parameters given
		echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
	else
		if [ -f $1 ] ; then
			# NAME=${1%.*}
			# mkdir $NAME && cd $NAME
			case $1 in
			  *.tar.bz2)   tar xvjf ../$1    ;;
			  *.tar.gz)    tar xvzf ../$1    ;;
			  *.tar.xz)    tar xvJf ../$1    ;;
			  *.lzma)      unlzma ../$1      ;;
			  *.bz2)       bunzip2 ../$1     ;;
			  *.rar)       unrar x -ad ../$1 ;;
			  *.gz)        gunzip ../$1      ;;
			  *.tar)       tar xvf ../$1     ;;
			  *.tbz2)      tar xvjf ../$1    ;;
			  *.tgz)       tar xvzf ../$1    ;;
			  *.zip)       unzip ../$1       ;;
			  *.Z)         uncompress ../$1  ;;
			  *.7z)        7z x ../$1        ;;
			  *.xz)        unxz ../$1        ;;
			  *.exe)       cabextract ../$1  ;;
			  *)           echo "extract: '$1' - unknown archive method" ;;
			esac
		else
			echo "$1 - file does not exist"
		fi
	fi
}


function gdb {
	# auto-resize window for ideal gdb usage
	# ref: http://apple.stackexchange.com/a/47841/153340
	local OLD_ROWS=$LINES
	local OLD_COLS=$COLUMNS
	printf "\e[8;30;125t"  # set size to 125x30
	$(which gdb) -q "$@"
	printf "\e[8;${OLD_ROWS};${OLD_COLS}t"   # reset back to original
}


# cool one-liner to print most-used commands from history:
# history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
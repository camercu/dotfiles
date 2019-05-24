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
			NAME=${1%.*}
			mkdir $NAME && cd $NAME
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



function cdf() {
    # change directory to current finder directory
    # source: https://apple.stackexchange.com/questions/12161/os-x-terminal-must-have-utilities
    target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
    if [ "$target" != "" ]; then
        cd "$target"; pwd
    else
        echo 'No Finder window found' >&2
    fi
}


function brewrm() {
        if [ -z "$1" ]; then
                # display usage if no parameters given
                echo "Usage: brewrm <program-name>"
		echo "  -Uninstalls/removes program and all dependencies"
        else
		brew rm "$1" && brew rm $(join <(brew leaves) <(brew deps "$1"))
	fi
}


# cool one-liner to print most-used commands from history:
# history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10


# Homebrew Cask - Global Applications Folder
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Homebrew PATH
export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"

# Homebrew bash-completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi

# Load .bashrc if it exists
test -f ~/.bashrc && source ~/.bashrc

# Master Password Name
export MP_FULLNAME="Cameron Charles Unterberger"

# Setting PATH for Python 2.7
# export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"

# pip should only run if there is a virtualenv currently activated
# export PIP_REQUIRE_VIRTUALENV=true

# ls colors <https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/ls.1.html>
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd # default Linux colors
# export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx # for black background
# export LSCOLORS=ExFxCxDxBxegedabagacad # white background

# ensure proper line-wrapping when scrolling through previous commands
shopt -s checkwinsize


#-------------------------------------
# BEGIN Udacity Git Customization
#-------------------------------------

# Enable git tab completion:
# source ~/.git-completion.bash
#   ^^ no longer needed. 
# By putting file in /opt/local/etc/bash_completion.d, Mac terminal runs it automatically
# file found at: https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# text (foreground) colors!
_COL_BLACK=$(tput setaf 0)
_COL_RED=$(tput setaf 1)
_COL_GREEN=$(tput setaf 2)
_COL_YELLOW=$(tput setaf 3)
_COL_BLUE=$(tput setaf 4)
_COL_MAGENTA=$(tput setaf 5)
_COL_CYAN=$(tput setaf 6)
_COL_WHITE=$(tput setaf 7)
_COL_DEFAULT=$(tput setaf 9)
_RESET_ALL=$(tput sgr0) # reset all attributes
# see url for more codes: http://wiki.bash-hackers.org/scripting/terminalcodes
# and for more ideas on terminal prompts: http://mywiki.wooledge.org/BashFAQ/053


# Change command prompt
source ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
# '\u' adds the name of the current user to the prompt
# '\$(__git_ps1)' adds git-related stuff
# '\W' adds the name of the current directory
export PS1="\[$_COL_YELLOW\]\u\[$_COL_CYAN\]\$(__git_ps1)\[$_COL_WHITE\] \W \$ \[$_RESET_ALL\]"

#-------------------------------------
# END Udacity Git Customization
#-------------------------------------

#######################################################
# Personal environment variables and startup programs.
#######################################################

# NOTE: Archived in git repository: 
# "/Users/cameron/Coding/Languages/BASH and Terminal/Terminal Setup"

# Personal aliases and functions should go in ~/.bashrc.  System wide
# environment variables and startup programs are in /etc/profile.
# System wide aliases and functions are in /etc/bashrc.


# Load .bashrc if it exists
test -f ~/.bashrc && source ~/.bashrc

# Homebrew Cask - Global Applications Folder
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Homebrew PATH
export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"

# Homebrew bash-completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi

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


#---------------------------------------
# BEGIN Bash Prompt Customization w/ Git
#---------------------------------------

# text (foreground) colors!
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
DEFAULT=$(tput setaf 9)
_RESET_ALL=$(tput sgr0) # reset all attributes
# see url for more codes: http://wiki.bash-hackers.org/scripting/terminalcodes
# and for more ideas on terminal prompts: http://mywiki.wooledge.org/BashFAQ/053

# Change command prompt
source ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1

# Fancy unicode globe character! (for admin prompt)
GLOBECHAR=$'\xf0\[\x9f\x8c\x8e\] '

# Admin Prompt
# export PS1="${GLOBECHAR}\[$YELLOW\] \w \$ \[$_RESET_ALL\]"

# My prompt
export PS1="\[$YELLOW\]\u\[$CYAN\]\$(__git_ps1)\[$WHITE\] \W \$ \[$_RESET_ALL\]"
  # note: PS1 needs '\[' and '\]' to escape non-printable characters, 
  # keeping char count in line w/ displayed text (new line happens at right place).
  # '\u' adds the name of the current user to the prompt.
  # '\$(__git_ps1)' adds git-related stuff.
  # '\W' adds the name of the current directory.

unset BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE DEFAULT _RESET_ALL GLOBECHAR

#-------------------------------------
# END Prompt Customization
#-------------------------------------


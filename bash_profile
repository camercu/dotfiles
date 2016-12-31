#######################################################
# Personal environment variables and startup programs.
#######################################################
# Personal aliases and functions should go in ~/.bashrc.  System wide
# environment variables and startup programs are in /etc/profile.
# System wide aliases and functions are in /etc/bashrc.


# Load .bashrc if it exists
test -e ~/.bashrc && source ~/.bashrc

# Master Password Name
export MP_FULLNAME="Cameron Charles Unterberger"

# set up the editor for programs that want them
export EDITOR='nano'
export VISUAL='nano'

# enable "**" (globstar): recurse all subdirectories from current
if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then  # only supported in v4.0+
	shopt -s globstar
fi

# enable Ctrl+O to function properly (disables stty key binding so inputrc
# key binding takes over)
stty discard undef

# for capstone disassembler libraries:
# http://www.capstone-engine.org/
#export DYLD_LIBRARY_PATH=/usr/local/opt/capstone/lib/:$DYLD_LIBRARY_PATH

#---------------------------------------
# Homebrew settings
#---------------------------------------
# Homebrew Cask - Global Applications Folder
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Homebrew API Token for more access to GitHub
source ~/.dotfiles/.github-api-token

# Homebrew PATH
# export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
# ^^ no longer needed because I manually changed the /etc/profile and /etc/paths
# files to set this order as desired.
# NOTE: for future appending of items to path, can use files in /etc/path.d
# along with /usr/libexec/path_helper tool to (man page: path_helper(8))
# ref: http://www.softec.lu/site/DevelopersCorner/MasteringThePathHelper

# Homebrew bash-completion
if [ -e $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi



#---------------------------------------
# History settings
#---------------------------------------
# Ensure history appends to disk (rather than overwrite, when multi windows open).
shopt -s histappend
PROMPT_COMMAND=update_terminal_cwd; history -a

# save multiline commands as one command
shopt -s cmdhist

# No duplicate entries in history. Also ignore (don't put in history)
# duplicate commands and commands preceded by a space (useful if you don't
# want a command recorded in your history
HISTCONTROL="erasedups:ignoreboth"

# Big(ish) history file
HISTFILESIZE=5000	# lines stored on disk
HISTSIZE=1000	# lines stored in RAM
HISTFILE=~/.bash_history

# have bash display expanded history commands before executing (paranoid)
shopt -s histverify # somewhat redundant with magic-space

# don't put 'exit' and 'history' commands in history
# can string commands together with "cmd1:cmd2"
# wildcard "*" also ok
HISTIGNORE="logout:exit:history*"

# ensure proper line-wrapping when scrolling through previous commands
shopt -s checkwinsize

# small typos ignored in directory names
shopt -s cdspell



#---------------------------------------
# Bash Prompt Customization
#---------------------------------------

# text (foreground) colors!
COLOR_BLACK=$(tput setaf 0)
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
COLOR_BLUE=$(tput setaf 4)
COLOR_MAGENTA=$(tput setaf 5)
COLOR_CYAN=$(tput setaf 6)
COLOR_WHITE=$(tput setaf 7)
COLOR_DEFAULT=$(tput setaf 9)
# see url for more codes: http://wiki.bash-hackers.org/scripting/terminalcodes
# and for more ideas on terminal prompts: http://mywiki.wooledge.org/BashFAQ/053
# also: terminfo(5)

# Other text modes:
ATTR_RESET=$(tput sgr0) # turn off all attributes
ATTR_UNDERLINE=$(tput smul)
ATTR_BOLD=$(tput bold) # extra-bright mode
ATTR_ITALICS=$(tput sitm)
ATTR_BLINK=$(tput blink)
ATTR_DIM=$(tput dim) # half-bright mode
ATTR_STANDOUT=${ATTR_RESET}$(tput smso)

ATTR_UNDERLINE_OFF=$(tput rmul)
ATTR_ITALICS_OFF=$(tput ritm)
ATTR_STANDOUT_OFF=$(tput rmso)


# Change command prompt
source ~/.git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1

# Fancy unicode globe character! (for admin prompt)
GLOBECHAR=$'\xf0\[\x9f\x8c\x8e\] '

case $USER in
?admin )
	# Admin Prompt (globe and git info)
	PS1="\[$ATTR_RESET\]${GLOBECHAR}\[$COLOR_CYAN\]\$(__git_ps1)\[$COLOR_WHITE\] \w \$ \[$ATTR_RESET\]"
	;;
* )
	# My prompt (show git info)
	PS1="\[$ATTR_RESET\]\[$COLOR_YELLOW\]\u\[$COLOR_CYAN\]\$(__git_ps1)\[$COLOR_WHITE\] \W \$ \[$ATTR_RESET\]"
		# note: PS1 needs '\[' and '\]' to escape non-printable characters,
		# keeping char count in line w/ displayed text (new line happens at right place).
		# '\u' adds the name of the current user to the prompt.
		# '\$(__git_ps1)' adds git-related stuff.
		# '\W' adds the name of the current directory.
	;;
esac

unset GLOBECHAR


#-------------------------------------
# Manpages coloring
#-------------------------------------
# source: http://www.tuxarena.com/2012/04/tutorial-colored-man-pages-how-it-works/
export LESS_TERMCAP_mb=${ATTR_BOLD}${COLOR_RED} # enter blinking mode
export LESS_TERMCAP_md=${ATTR_BOLD}${COLOR_MAGENTA} # enter bold mode
export LESS_TERMCAP_me=${ATTR_RESET} # turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=${ATTR_RESET} # exit standout mode
export LESS_TERMCAP_so=${ATTR_STANDOUT}${ATTR_BOLD}${COLOR_YELLOW} # enter standout mode
export LESS_TERMCAP_us=${ATTR_UNDERLINE}${COLOR_CYAN} # enter underline mode
export LESS_TERMCAP_ue=${ATTR_RESET} # exit underline mode



#-------------------------------------
# ls/grep colors
#-------------------------------------
# Manpage: <https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/ls.1.html>
# Simplified source: http://osxdaily.com/2012/02/21/add-color-to-the-terminal-in-mac-os-x/
# LS color generator: http://geoff.greer.fm/lscolors/
export CLICOLOR=1
export LSCOLORS=ExGxFxdxBxafacBeBgEhEd
# export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd # default Linux colors
# export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx # for black background
# export LSCOLORS=ExFxCxDxBxegedabagacad # white background

# Tell grep to highlight matches
export GREP_OPTIONS='--color=auto'



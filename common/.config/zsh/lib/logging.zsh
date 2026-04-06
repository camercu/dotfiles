# Colour codes — resolved once at source time to avoid per-call tput subprocesses.
# Skip when stderr is not a TTY (piped output, zsh -c, CI) to avoid embedding
# escape sequences and to avoid the fork cost entirely in non-interactive contexts.
if [[ -t 2 ]] && is-installed tput; then
  typeset -g _LOG_BLUE=$(tput setaf 4)
  typeset -g _LOG_YELLOW=$(tput setaf 3)
  typeset -g _LOG_RED=$(tput setaf 1)
  typeset -g _LOG_GREEN=$(tput setaf 2)
  typeset -g _LOG_CLEAR=$(tput sgr0)
else
  typeset -g _LOG_BLUE='' _LOG_YELLOW='' _LOG_RED='' _LOG_GREEN='' _LOG_CLEAR=''
fi

function debug   { print -- "${_LOG_BLUE}[*] $*${_LOG_CLEAR}"   >&2; }
function warn    { print -- "${_LOG_YELLOW}[!] $*${_LOG_CLEAR}"  >&2; }
function error   { print -- "${_LOG_RED}[x] $*${_LOG_CLEAR}"    >&2; }
function success { print -- "${_LOG_GREEN}[+] $*${_LOG_CLEAR}"  >&2; }

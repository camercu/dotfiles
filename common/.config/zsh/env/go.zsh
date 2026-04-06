# Golang PATH
[[ -d "/usr/local/go/bin" ]] && export PATH="$PATH:/usr/local/go/bin"
if is-installed go; then
    export GOPATH="${GOPATH:-${XDG_CACHE_HOME:-$HOME/.cache}/go}"
    export PATH="$PATH:${GOPATH}/bin"
fi

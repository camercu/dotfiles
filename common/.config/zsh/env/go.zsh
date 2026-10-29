# Golang PATH
[[ -d "/usr/local/go/bin" ]] && export PATH="$PATH:/usr/local/go/bin"
if is-installed go; then  # GOPATH: go.sh
    export PATH="$PATH:${GOPATH}/bin"
fi

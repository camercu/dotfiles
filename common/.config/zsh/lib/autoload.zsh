# autoload-dir: add directories to fpath and autoload their function files.
# Files beginning with _ are excluded (zsh completion function convention).
function autoload-dir {
    local root zdir
    local -a zautoloads
    setopt EXTENDED_GLOB LOCAL_OPTIONS
    for root in "$@"; do
        [[ -d "$root" ]] || continue
        for zdir in "$root" "$root"/***(/N); do
            fpath=("$zdir" $fpath)
            # Glob: regular files, exclude _* names (completion functions), return basenames
            zautoloads=("$zdir"/*~_*(N-:t))
            (( $#zautoloads > 0 )) && autoload -Uz $zautoloads
        done
    done
}

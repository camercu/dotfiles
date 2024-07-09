#!/usr/bin/env zsh


# Autoload function files in directory by adding
# to fpath and calling autoload on each file in directory.
# source: https://github.com/mattmc3/zdotdir/blob/main/lib/autoload.zsh
function autoload-dir {
    local zdir
    local -a zautoloads
    setopt EXTENDED_GLOB LOCAL_OPTIONS
    for zdir in $@; do
        [[ -d "$zdir" ]] || continue
        fpath=("$zdir" $fpath)
        # match all plain files except those starting with underscore, grabbing basename of file, with NULL_GLOB set
        zautoloads=($zdir/*~_*(N.:t))
        (( $#zautoloads > 0 )) && autoload -Uz $zautoloads
    done
}

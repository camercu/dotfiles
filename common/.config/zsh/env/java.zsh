#!/usr/bin/env zsh

if [[ -x /usr/libexec/java_home ]]; then
    _java_cache="${XDG_CACHE_HOME:-$HOME/.cache}/java_home_17"
    if [[ ! -f "$_java_cache" ]]; then
        /usr/libexec/java_home -v 17 2>/dev/null > "$_java_cache" || rm -f "$_java_cache"
    fi
    [[ -s "$_java_cache" ]] && export JAVA_HOME="$(<"$_java_cache")"
    unset _java_cache
fi

#!/usr/bin/env zsh

if [[ -e /usr/lib/java_home ]]; then
    export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
fi

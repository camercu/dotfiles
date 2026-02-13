#!/usr/bin/env zsh

if [[ -x /usr/libexec/java_home ]]; then
    if JAVA_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null)"; then
        export JAVA_HOME
    fi
fi

#!/usr/bin/env zsh

# Prefer platform command-not-found handlers; fall back to styled local output.
function command_not_found_handler {
    local cmd="$1"
    shift

    if [[ -x /opt/homebrew/bin/brew ]] && [[ -x /opt/homebrew/bin/brew-cmd-not-found ]]; then
        /opt/homebrew/bin/brew-cmd-not-found "$cmd"
        return $?
    fi
    if [[ -x /usr/lib/command-not-found ]]; then
        /usr/lib/command-not-found -- "$cmd"
        return $?
    fi
    if [[ -x /usr/share/command-not-found/command-not-found ]]; then
        /usr/share/command-not-found/command-not-found -- "$cmd"
        return $?
    fi
    if [[ -x /usr/libexec/pk-command-not-found ]] && [[ -S /var/run/dbus/system_bus_socket ]] && [[ -x /usr/libexec/packagekitd ]]; then
        /usr/libexec/pk-command-not-found "$cmd" "$@"
        return $?
    fi
    if [[ -x /run/current-system/sw/bin/command-not-found ]]; then
        /run/current-system/sw/bin/command-not-found "$cmd" "$@"
        return $?
    fi
    if [[ -x /usr/bin/command-not-found ]]; then
        /usr/bin/command-not-found "$cmd"
        return $?
    fi

    local RED_UNDERCURL="\033[4:3m\033[58:5:1m"
    printf "%sERROR:%s command \`%s\` not found.\n" \
        "$(printf $BOLD_RED)" "$(printf $RESET)" \
        "$(printf $RED_UNDERCURL)${cmd}$(printf $RESET)" \
        >&2
    return 127
}

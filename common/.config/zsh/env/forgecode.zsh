#!/usr/bin/env zsh


# Add required zsh plugins if not already present
if [[ ! " ${plugins[@]} " =~ " zsh-autosuggestions " ]]; then
    plugins+=(zsh-autosuggestions)
fi
if [[ ! " ${plugins[@]} " =~ " zsh-syntax-highlighting " ]]; then
    plugins+=(zsh-syntax-highlighting)
fi

# Load forge shell plugin (commands, completions, keybindings) if not already loaded
if [[ -z "$_FORGE_PLUGIN_LOADED" ]]; then
    # Temporarily disable global -h alias (from bat.zsh) to prevent it from
    # intercepting 'typeset -h ...' declarations in the forge plugin output.
    typeset _h_alias_saved=
    if [[ -n "${aliases[-h]+_}" ]]; then
        _h_alias_saved="${aliases[-h]}"
        unalias -- '-h'
    fi
    eval "$(forge zsh plugin)"
    if [[ -n "$_h_alias_saved" ]]; then
        alias -g -- -h="$_h_alias_saved"
    fi
    unset _h_alias_saved
fi

# Load forge shell theme (prompt with AI context) if not already loaded
if [[ -z "$_FORGE_THEME_LOADED" ]]; then
    eval "$(forge zsh theme)"
fi


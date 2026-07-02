#!/usr/bin/env zsh
# Prune stale dotfile symlinks: broken links under ~, ~/.config, and ~/.local
# whose target points into this repo — leftovers when a stowed file is moved
# or deleted (stow -D only unlinks files still present in a package).
# Not a full uninstaller: run scripts/uninstall-dotfiles.sh first to remove
# the healthy links; see the README's Uninstall section.

setopt ERR_EXIT NO_UNSET PIPE_FAIL

DOTFILE_DIR=${0:a:h}

for link in ~/*(D-@N) ~/.config/**/*(D-@N) ~/.local/**/*(D-@N); do
    # :A cannot resolve a broken link (realpath fails and falls back to the
    # link's own path), so read the target and absolutize it lexically.
    target=$(command readlink -- "$link")
    if [[ $target != /* ]]; then
        target=${link:h}/$target
    fi
    [[ ${target:a} == "$DOTFILE_DIR"/* ]] || continue
    rm -v -- "$link"
done

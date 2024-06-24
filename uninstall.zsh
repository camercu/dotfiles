#!/usr/bin/env zsh
# WARNING: Not a robust uninstaller!!
#
# This file just removes broken symlinks from your home dir

# Delete all broken symlinks in the home dir
rm -iv -- ~/*(D-@)
# Delete all broken symlinks in the config dir
rm -iv -- ~/.config/**/*(D-@)
# Delete all broken symlinks in the user's local dir
rm -iv -- ~/.local/**/*(D-@)

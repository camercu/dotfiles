#!/usr/bin/env zsh

# +--------------------+
# | NAVIGATION OPTIONS |
# +--------------------+
#
# https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories

setopt AUTO_CD              # Go to folder path without using cd.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt CD_SILENT            # Do not print the working directory after cd.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_MINUS          # Swap meaning of +/- to specify directory on stack.
setopt PUSHD_TO_HOME        # Pushd with no args goes to $HOME

#!/bin/sh
# Nothing here needs zsh: the installer is run under bash by upstream's own
# instructions, so this wrapper stays POSIX sh.

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

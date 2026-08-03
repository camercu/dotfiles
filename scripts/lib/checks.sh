#!/bin/sh
#
# checks.sh: shared POSIX predicate helpers for the install/bootstrap scripts
# and dotsync. Companion to logging.sh (info/debug/warn/error/success).
#
# POSIX sh forbids hyphens in function names, so these use underscores
# (is_macos, not is-macos). The interactive shells keep their own hyphenated
# copies for their own reasons:
#   - common/.config/zsh/lib/env-checks.zsh  (interactive zsh)
#   - common/.bash_aliases                   (interactive bash + zsh)
# Keep the semantics of all three in sync.

is_macos()   { [ "$(uname -s)" = "Darwin" ]; }
is_linux()   { [ "$(uname -s)" = "Linux" ]; }
is_bsd()     { case "$(uname -s)" in *BSD) return 0 ;; *) return 1 ;; esac; }
is_solaris() { [ "$(uname -s)" = "SunOS" ]; }
is_windows() { case "$(uname -s)" in CYGWIN*|MINGW*|MSYS*) return 0 ;; *) return 1 ;; esac; }

# is_installed: true if an external command is on PATH.
is_installed() { command -v "$1" >/dev/null 2>&1; }

# is_admin: true if the current user is in the macOS "admin" group.
# grep -x (exact line) avoids matching group names that merely contain "admin".
is_admin() { id -Gn 2>/dev/null | tr ' ' '\n' | grep -qx 'admin'; }

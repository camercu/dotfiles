# Logging (info/debug/warn/error/success) is shared with interactive bash and
# the repo's install scripts, so the implementation lives in POSIX sh:
# ~/.config/sh/logging.sh, common/.config/sh/logging.sh in the repo. Both files
# come from the same stow package, so one being linked means the other is too;
# a failure here is a broken install and should be loud.
builtin source "${XDG_CONFIG_HOME:-$HOME/.config}/sh/logging.sh"

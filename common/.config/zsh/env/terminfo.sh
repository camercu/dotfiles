# Home Manager installs terminal entries (xterm-ghostty) into the nix profile,
# where a distro's ncurses never looks. With nothing inherited, the trailing
# empty element keeps ncurses' compiled-in system dirs in the search.
if [ -d "$HOME/.nix-profile/share/terminfo" ]; then
  case ":${TERMINFO_DIRS-}:" in
    *":$HOME/.nix-profile/share/terminfo:"*) ;;
    *) export TERMINFO_DIRS="$HOME/.nix-profile/share/terminfo:${TERMINFO_DIRS-}" ;;
  esac
fi

# xterm-ghostty for every account (su, ssh, a fresh host before the Ghostty
# cask lands), compiled from the vendored source: ghostty-bin.terminfo would
# fetch the whole DMG for it.
{pkgs}:
pkgs.runCommand "ghostty-terminfo" {nativeBuildInputs = [pkgs.ncurses];} ''
  mkdir -p $out/share/terminfo
  tic -x -o $out/share/terminfo ${./xterm-ghostty.terminfo}
''

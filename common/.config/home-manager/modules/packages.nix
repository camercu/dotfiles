{lib, pkgs, ...}: let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  home.packages =
    with pkgs;
      [
        bat
        fd
        fzf
        git
        lazygit
        neovim
        ripgrep
        tmux
        tree-sitter
        zoxide
      ]
      ++ lib.optionals isDarwin [
        pngpaste
      ]
      ++ lib.optionals isLinux [
        wl-clipboard
      ];
}

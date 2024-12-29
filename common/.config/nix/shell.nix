{ pkgs ? import <nixpkgs> {} }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
pkgs.mkShellNoCC {
  packages = with pkgs; [
    # Common packages
    clang
    fd
    fzf
    git
    go
    lazygit
    neovim
    nodejs
    nodenv
    ripgrep
    rustup
    stow
    tmux
    tree-sitter
    zsh
  ]
    ++ lib.optionals (isDarwin) [
      # MacOS only packages
    ]

  ++ lib.optionals (isLinux) [
      # Linux only packages
    ]

    # Install all Nerd Fonts
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}

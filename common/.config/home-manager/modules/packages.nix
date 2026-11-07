{
  config,
  lib,
  pkgs,
  ...
}: let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  options.dotfiles.systemGhostty = lib.mkEnableOption
    "Ghostty from a system package instead of nix (its terminfo still comes from nix)";

  config.home.packages =
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
      ++ lib.optionals (isLinux && !config.dotfiles.systemGhostty) [ghostty]
      ++ lib.optionals isLinux [
        # Listed on its own so hosts reached over ssh keep xterm-ghostty even
        # without the GUI app; env/terminfo.sh puts it on TERMINFO_DIRS.
        ghostty.terminfo
        # linux/.config/git/config-credential runs it from the profile.
        git-credential-manager
        wl-clipboard
        # The Mac gets these from nix-darwin (crank-pkgs.nix, ark-pkgs.nix).
        delta # git's pager
        entr
        jq
        lsd # backs the ls aliases
        procs
        tealdeer
        xh
        rustup # homes set in env/rust.sh; toolchain below
        # Named by ghostty/config and the xfce panel's genmon plugin.
        nerd-fonts.meslo-lg
        nerd-fonts.fira-code
      ];

  config.fonts.fontconfig.enable = isLinux;

  # rustup from nix ships no toolchain. Install stable once, at the homes
  # env/rust.sh gives the shell; later updates are `rustup update`.
  config.home.activation.rustupStable = lib.mkIf isLinux (
    lib.hm.dag.entryAfter ["installPackages"] ''
      export RUSTUP_HOME="${config.xdg.dataHome}/rustup"
      export CARGO_HOME="${config.xdg.dataHome}/cargo"
      if ! ${pkgs.rustup}/bin/rustup default >/dev/null 2>&1; then
        run ${pkgs.rustup}/bin/rustup default stable
      fi
    ''
  );

  # Standalone Home Manager on a non-NixOS distro: nix GUI apps (ghostty)
  # need the host GPU drivers linked into /run/opengl-driver. Activation
  # prints the one-time `sudo non-nixos-gpu-setup` step that does this.
  config.targets.genericLinux.enable = isLinux;
}

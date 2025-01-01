{
  description = "My nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # https://discourse.nixos.org/t/declarative-package-management-on-macos-without-home-manager-or-nix-darwin/43467/3
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    flake-utils,
  }: let
    configuration = {
      pkgs,
      lib,
      ...
    }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        alejandra # nix formatter
        cargo # LazyVim dependency
        clang # LazyVim dependency
        fd # LazyVim dependency
        fzf # LazyVim dependency
        git
        go # LazyVim dependency
        lazygit # LazyVim dependency
        neovim
        nodejs # LazyVim dependency
        nodenv
        ripgrep # LazyVim dependency
        rustup # LazyVim dependency
        stow # for stowing dotfiles
        tmux
        tree-sitter # LazyVim dependency
        zsh
      ];

      # Install Nerd Fonts
      fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

      # Manage Homebrew Casks
      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall";
        casks = [
          "1password"
          "1password-cli"
          "wezterm"
        ];
      };

      # Keep zsh updated
      programs.zsh.enable = true;

      # Enable touch ID for sudo
      security.pam.enableSudoTouchIdAuth = true;

      # Manage the nix-daemon
      services.nix-daemon.enable = true;

      # Nix settings
      nix.settings = {
        use-xdg-base-directories = true;
        experimental-features = "nix-command flakes";
      };

      # Nixpkgs
      nixpkgs.config = {allowUnfree = true;};

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;
    };
    macos-apple-silicon = {
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
    macos-intel = {
      nixpkgs.hostPlatform = "x86_64-darwin";
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#TheRoci
    darwinConfigurations."TheRoci" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        macos-apple-silicon
      ];
    };
  };
}

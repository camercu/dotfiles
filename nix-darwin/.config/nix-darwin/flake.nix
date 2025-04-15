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
      # Packages installed in every profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        alejandra # nix formatter
        fd # LazyVim dependency
        fzf # LazyVim dependency
        git
        go # LazyVim dependency
        lazygit # LazyVim dependency
        neovim
        nodejs # LazyVim dependency
        nodenv
        python3
        ripgrep # LazyVim dependency
        rustup # LazyVim dependency
        stow # for stowing dotfiles
        tmux
        tree-sitter # LazyVim dependency
        uv # python pip replacement
        zsh
      ];

      # necessary hack for "su -" to work with Ghostty
      environment.variables = {
        TERMINFO_DIRS = ["/Applications/Ghostty.app/Contents/Resources/terminfo"];
        GHOSTTY_RESOURCES_DIR = "/Applications/Ghostty.app/Contents/Resources/ghostty";
      };

      # Activation scripts to run on switch
      system.activationScripts.postActivation.text = ''
        # Install rust toolchain
        rustup default stable
      '';

      # Manage core Homebrew Casks
      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall";
        casks = [
          "1password"
          "1password-cli"
          "ghostty"
        ];
      };

      # Manage zsh, source nix environment in /etc/zshenv
      programs.zsh.enable = true;

      # Enable touch ID for sudo
      security.pam.services.sudo_local.touchIdAuth = true;

      # Nix settings
      nix.settings = {
        allowed-users = [
          "@admin"
          "cameron"
          "crank"
        ];
        always-allow-substitutes = true; # from determinate-systems nix installer
        build-users-group = "nixbld";
        experimental-features = ["nix-command" "flakes"];
        extra-nix-path = "nixpkgs=flake:nixpkgs"; # from determinate-systems nix installer
        extra-trusted-public-keys = "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio= cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU= cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU= cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8= cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ= cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o= cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y="; # from determinate-systems nix installer
        extra-trusted-substituters = "https://cache.flakehub.com"; # from determinate-systems nix installer
        trusted-users = [
          "@admin"
        ];
        upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal"; # from determinate-systems nix installer
        use-xdg-base-directories = true;
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
    # $ darwin-rebuild build --flake .#Roci
    darwinConfigurations."Roci" = nix-darwin.lib.darwinSystem {
      modules = [
        ./crank-pkgs.nix
        configuration
        macos-apple-silicon
      ];
    };
    darwinConfigurations."Tachi" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        macos-intel
      ];
    };
  };
}

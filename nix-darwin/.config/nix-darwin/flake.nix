{
  description = "My nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
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
        statix # nix linter, for neovim
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

      system = {
        # Activation scripts to run on switch
        activationScripts.postActivation.text = ''
          # nothing for now...
        '';

        # Set Git commit hash for darwin-version.
        configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        stateVersion = 5;
      };
    };
    mkHost = {
      platform,
      primaryUser ? null,
      extraModules ? [],
    }:
      nix-darwin.lib.darwinSystem {
        modules =
          [
            configuration
            {nixpkgs.hostPlatform = platform;}
          ]
          ++ nixpkgs.lib.optional (primaryUser != null) {system.primaryUser = primaryUser;}
          ++ extraModules;
      };
    hosts = {
      "Roci" = {
        platform = "aarch64-darwin";
        primaryUser = "cadmin";
        extraModules = [./crank-pkgs.nix];
      };
      "Tachi" = {
        platform = "x86_64-darwin";
      };
      "TheArk" = {
        # kids laptop
        platform = "aarch64-darwin";
      };

      "Jessie's Laptop" = {
        platform = "aarch64-darwin";
      };
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Roci
    darwinConfigurations = nixpkgs.lib.mapAttrs (_: mkHost) hosts;
  };
}

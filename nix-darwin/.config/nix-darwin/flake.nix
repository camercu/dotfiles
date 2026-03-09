{
  description = "My nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    determinate,
    home-manager,
    nix-darwin,
    nixpkgs,
  }: let
    hmRoot = ../../../common/.config/home-manager;
    hmHostData = import (hmRoot + "/lib/hosts.nix") {lib = nixpkgs.lib;};
    hmCommonModule = hmRoot + "/home.nix";
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
          "font-meslo-lg-nerd-font"
          "ghostty"
        ];
      };

      # Manage zsh, source nix environment in /etc/zshenv
      programs.zsh.enable = true;

      # Enable touch ID for sudo
      security.pam.services.sudo_local.touchIdAuth = true;

      # The installer uses Determinate Nix, so nix-darwin must not manage the
      # Nix daemon or /etc/nix/nix.conf on these hosts.
      nix.enable = false;

      determinateNix = {
        enable = true;
        customSettings = {
          allowed-users = [
            "@admin"
            "cameron"
            "crank"
          ];
          always-allow-substitutes = "true";
          build-users-group = "nixbld";
          experimental-features = "nix-command flakes";
          extra-trusted-public-keys = "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio= cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU= cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU= cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8= cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ= cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o= cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y=";
          extra-trusted-substituters = "https://cache.flakehub.com";
          trusted-users = ["@admin"];
          use-xdg-base-directories = "true";
        };
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
      homeManagerConfigName ? null,
      extraModules ? [],
    }:
      let
        homeHost =
          if homeManagerConfigName == null
          then null
          else hmHostData.byName.${hmHostData.normalizeName homeManagerConfigName} or null;
      in
        nix-darwin.lib.darwinSystem {
          modules =
            [
              configuration
              determinate.darwinModules.default
              home-manager.darwinModules.home-manager
              {nixpkgs.hostPlatform = platform;}
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
              }
            ]
            ++ nixpkgs.lib.optional (primaryUser != null) {system.primaryUser = primaryUser;}
            ++ nixpkgs.lib.optional (homeHost != null) {
              home-manager.users.${homeHost.username} = {
                imports = [hmCommonModule];
                home.homeDirectory =
                  if homeHost.homeDirectory != ""
                  then homeHost.homeDirectory
                  else "/Users/${homeHost.username}";
              };
            }
            ++ extraModules;
        };
    hosts = {
      "Roci" = {
        platform = "aarch64-darwin";
        primaryUser = "cadmin";
        homeManagerConfigName = "roci";
        extraModules = [./crank-pkgs.nix];
      };
      "Tachi" = {
        platform = "x86_64-darwin";
        homeManagerConfigName = "tachi";
      };
      "TheArk" = {
        # kids laptop
        platform = "aarch64-darwin";
        primaryUser = "kadmin";
        homeManagerConfigName = "theark";
        extraModules = [./ark-pkgs.nix];
      };

      "Jessie's Laptop" = {
        platform = "aarch64-darwin";
        primaryUser = "jadmin";
        homeManagerConfigName = "jessieslaptop";
      };
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Roci
    darwinConfigurations = nixpkgs.lib.mapAttrs (_: mkHost) hosts;
  };
}

{
  description = "Dotfiles, Home Manager, and nix-darwin configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgsDarwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgsDarwin";
    };
  };

  outputs = {
    self,
    determinate,
    home-manager,
    nix-darwin,
    nixpkgs,
    nixpkgsDarwin,
    ...
  }: let
    lib = nixpkgs.lib;
    dotfilesRoot = ./.;
    hmRoot = dotfilesRoot + "/common/.config/home-manager";
    hmHostData = import (hmRoot + "/lib/hosts.nix") {inherit lib;};
    hmCommonModule = hmRoot + "/home.nix";

    mkHome = {
      system,
      username,
      homeDirectory ? null,
      extraModules ? [],
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          inherit dotfilesRoot;
        };
        modules =
          [
            hmCommonModule
            {
              home.username = username;
              home.homeDirectory =
                if homeDirectory != null
                then homeDirectory
                else if builtins.match ".*-darwin" system != null
                then "/Users/${username}"
                else "/home/${username}";
            }
          ]
          ++ extraModules;
      };

    darwinBaseModule = {
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        alejandra
        fd
        fzf
        git
        go
        lazygit
        neovim
        nodejs
        nodenv
        python3
        ripgrep
        rustup
        statix
        stow
        tmux
        tree-sitter
        uv
        zsh
      ];

      environment.variables = {
        TERMINFO_DIRS = ["/Applications/Ghostty.app/Contents/Resources/terminfo"];
        GHOSTTY_RESOURCES_DIR = "/Applications/Ghostty.app/Contents/Resources/ghostty";
      };

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

      programs.zsh.enable = true;
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

      nixpkgs.config = {allowUnfree = true;};

      system = {
        activationScripts.postActivation.text = ''
          # nothing for now...
        '';
        configurationRevision = self.rev or self.dirtyRev or null;
        stateVersion = 5;
      };
    };

    mkDarwinHost = {
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
              darwinBaseModule
              determinate.darwinModules.default
              home-manager.darwinModules.home-manager
              {nixpkgs.hostPlatform = platform;}
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = {
                  inherit dotfilesRoot;
                };
              }
            ]
            ++ lib.optional (primaryUser != null) {system.primaryUser = primaryUser;}
            ++ lib.optional (homeHost != null) {
              users.users.${homeHost.username} = {
                name = homeHost.username;
                home =
                  if homeHost.homeDirectory != ""
                  then homeHost.homeDirectory
                  else "/Users/${homeHost.username}";
              };

              home-manager.users.${homeHost.username}.imports = [hmCommonModule];
            }
            ++ extraModules;
        };

    darwinHosts = [
      {
        configName = "roci";
        displayName = "Roci";
        platform = "aarch64-darwin";
        primaryUser = "cadmin";
        homeManagerConfigName = "roci";
        extraModules = [(dotfilesRoot + "/nix-darwin/.config/nix-darwin/crank-pkgs.nix")];
      }
      {
        configName = "tachi";
        displayName = "Tachi";
        platform = "x86_64-darwin";
        homeManagerConfigName = "tachi";
      }
      {
        configName = "theark";
        displayName = "TheArk";
        platform = "aarch64-darwin";
        primaryUser = "kadmin";
        homeManagerConfigName = "theark";
        extraModules = [(dotfilesRoot + "/nix-darwin/.config/nix-darwin/ark-pkgs.nix")];
      }
      {
        configName = "jessieslaptop";
        displayName = "Jessie's Laptop";
        platform = "aarch64-darwin";
        primaryUser = "jadmin";
        homeManagerConfigName = "jessieslaptop";
      }
    ];

    darwinConfigurationsByDisplay =
      builtins.listToAttrs (map (host: {
          name = host.displayName;
          value = mkDarwinHost {
            inherit (host) platform;
            primaryUser = host.primaryUser or null;
            homeManagerConfigName = host.homeManagerConfigName or null;
            extraModules = host.extraModules or [];
          };
        })
        darwinHosts);

    darwinConfigurationsByConfig =
      builtins.listToAttrs (map (host: {
          name = host.configName;
          value = darwinConfigurationsByDisplay.${host.displayName};
        })
        darwinHosts);
  in {
    homeConfigurations =
      builtins.listToAttrs (map (host: {
          name = host.configName;
          value = mkHome {
            inherit (host) system username;
            homeDirectory =
              if host.homeDirectory == ""
              then null
              else host.homeDirectory;
          };
        })
        hmHostData.linuxHosts);

    darwinConfigurations = darwinConfigurationsByDisplay // darwinConfigurationsByConfig;
  };
}

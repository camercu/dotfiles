# Dotfiles

A [Nix](https://nixos.org/)-based dotfiles repository using a two-layer approach:

1. **GNU Stow** manages shell-managed dotfile symlinks (`.zshrc`, `.vimrc`, etc.).
2. **Nix flakes** (Home Manager and nix-darwin) manage declarative packages and user configuration.

## Hosts

Hosts are defined in `common/.config/home-manager/hosts.tsv` using this format:

```
config_name|system|username|home_directory|aliases|display_name|primary_user|darwin_extra_modules
```

The current host is auto-detected via `scutil --get ComputerName` (macOS) or `hostname -s` (Linux). You can override the active host with the `HOME_MANAGER_CONFIG` environment variable.

## Installation

### Full install

Run this on a fresh machine. It handles everything:

```sh
./install.sh
```

This script:

1. Installs bootstrap packages (`git`, `curl`, `zsh`) if needed
2. Calls `scripts/bootstrap-install.zsh` which:
    - Installs [Nix](https://zero-to-nix.com/) via [Determinate Installer](https://github.com/DeterminateSystems/nix-installer)
    - Links dotfiles via [dotsync](https://github.com/DeterminateSystems/dotsync) (stow-based)
    - Installs Homebrew on macOS (admin required)
    - Configures macOS defaults
    - Installs nix-darwin on macOS (admin required)
    - Optionally applies Home Manager on Linux (`USE_HOME_MANAGER=1`)

### Manual steps

If you want more control or Nix is already installed:

```sh
# 1. Clone the repo (if not already)
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles

# 2. Link dotfiles (stow-based)
./scripts/install-dotfiles.sh

# or equivalently:
./common/.local/bin/dotsync
```

On Linux, apply Home Manager after Nix is installed:

```sh
# Auto-detect the matching host config
./scripts/apply-home-manager.sh

# Or specify a config name explicitly
./scripts/apply-home-manager.sh somnambulist
```

You can override the host with `HOME_MANAGER_CONFIG`:

```sh
HOME_MANAGER_CONFIG=roci ./scripts/apply-home-manager.sh
```

## Daily usage

### `maintain` function

`maintain` (a shell function from `.bash_aliases`) is the primary daily maintenance command: one-shot, non-interactive, fails fast, never changes your cwd. It updates all managed software and dotfiles in one step. Its behavior differs by OS and account:

**macOS (admin):**
```sh
# git pull + submodule update (pinned) + dotsync + nix-darwin update + brew upgrade
maintain
```

**macOS (non-admin):**
```sh
# git pull + submodule update (float to upstream) + dotsync
maintain
```

**Linux (admin):**
```sh
# git pull + submodule update + dotsync + apt update/upgrade/autoremove/autoclean
maintain
```

Submodules are handled differently on purpose: the daily (non-admin) account floats them to upstream HEAD (`--remote --merge`) and commits the advanced pins; admin accounts reproduce the pinned SHAs. One account curates plugin versions, every other account follows.

On macOS every account also gets a quiet NixOS-release heads-up at the end: nothing is printed normally, and a `[!]` warning appears once the next release (see below) is fully cut and ready for `make upgrade`.

Note: nix-darwin and Homebrew updates require the admin account, which owns `~/.config/nix-darwin` and `/opt/homebrew`.

### macOS — nix-darwin

nix-darwin manages both system state and Home Manager user state. The repo root flake is the source of truth.

Rebuild from the repo root:

```sh
darwin-rebuild switch --flake path:$HOME/.dotfiles#TheArk
```

Update nix-darwin's flake inputs (stays within the pinned NixOS release):

```sh
cd nix-darwin/.config/nix-darwin
make update
# or manually:
darwin-flake-update
```

Cross to a new NixOS release (the ~6-monthly `YY.05`/`YY.11` bump — deliberate, admin-only; rewrites the pinned refs in `flake.nix`, then relocks and rebuilds):

```sh
make check-release            # human report: is the next release fully cut?
make check-release-ready      # machine-facing: prints the release only when ready (maintain uses this)
make upgrade RELEASE=26.11
```

### Linux — standalone Home Manager

On Linux, the root flake's `homeConfigurations` apply directly:

```sh
nix run home-manager/release-25.05 -- \
  switch --flake path:$HOME/.dotfiles#somnambulist
```

Or use the helper:

```sh
./scripts/apply-home-manager.sh
```

### Updating the root flake

```sh
nix flake update
```

## Dotfile management

### dotsync (stow)

The `common/.local/bin/dotsync` script (alias: `install-dotfiles.sh`) manages dotfile symlinks via GNU Stow:

```sh
# Link all active packages (common + OS-specific)
dotsync

# Unlink all managed symlinks
dotsync --unlink
```

On macOS, it stows `common/`, `macos/`, and `nix-darwin/` (admin required).
On Linux, it stows `common/` and `linux/`.

The `~/.stowrc` file sets the default target to `$HOME` and ignores `.stowrc` itself plus `.DS_Store`.

### Configuring hosts

Add or modify hosts in `common/.config/home-manager/hosts.tsv`. The first column (`config_name`) is used as the Home Manager/nix-darwin flake input name. Aliases in the `aliases` column are also resolved.

The `home-manager-host.sh` helper resolves active host information:

```sh
# Get the detected host config name
scripts/home-manager-host.sh current-config

# Get the detected host name
scripts/home-manager-host.sh current-name

# Resolve a config name from an alias
scripts/home-manager-host.sh resolve-config roci

# Look up the system architecture for a host
scripts/home-manager-host.sh lookup-system roci
```

## Uninstall

There is no robust uninstaller. This removes broken symlinks from your home directory:

```sh
./uninstall.zsh
```

For a complete uninstall, manually:

1. Run `./uninstall.zsh` to remove dotfile symlinks
2. Run `nix-uninstall` to remove Nix
3. Run `rm -rf /opt/homebrew` on macOS to remove Homebrew
4. Remove `~/.nix-profile`, `~/.nix-defexpr`, `~/.config/nix`
5. Remove `~/.home-manager-modules`

## Key files to customize

| File                                      | Purpose                                           |
| ----------------------------------------- | ------------------------------------------------- |
| `common/.config/home-manager/home.nix`    | Common Home Manager modules                       |
| `common/.config/home-manager/hosts.tsv`   | Host definitions                                  |
| `common/.config/zsh/`                     | Zsh environment, plugins, themes                  |
| `common/.config/nvim/`                    | Neovim configuration                              |
| `common/.config/git/`                     | Git configuration                                 |
| `common/.config/ghostty/`                 | Terminal emulator                                 |
| `nix-darwin/.config/nix-darwin/flake.nix` | nix-darwin per-host configuration                 |
| `flake.nix`                               | Root flake (packages, Home Manager, host routing) |

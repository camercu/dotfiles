# Personal settings and dotfiles

This repository uses a two-stage setup:

1. `scripts/install-dotfiles.sh` links dotfiles with only standard shell
   tools.
2. Home Manager applies declarative user packages and dotfiles after Nix is
   available.

This lets you bootstrap a typical Linux or macOS machine without requiring
`stow`, then move to declarative package management when Nix is installed.

## Bootstrap dotfiles

Use the dotfile installer when you need the dotfiles to work before Nix or
Home Manager is available.

```sh
./scripts/install-dotfiles.sh
```

The script links `common/` plus the current OS-specific tree. If it finds an
existing file at a target path, it moves that file into
`~/.dotfiles-backups/<timestamp>/` before linking the repository version.

## Apply Home Manager

Use Home Manager after Nix is installed to manage user packages and dotfiles
declaratively on both Linux and macOS.

```sh
./scripts/apply-home-manager.sh
```

The script auto-detects a matching configuration name from the current host:

- `Roci` -> `roci`
- `TheArk` -> `theark`
- `Tachi` -> `tachi`
- `Jessie's Laptop` -> `jessieslaptop`
- `somnambulist` -> `somnambulist`

You can override that detection with `HOME_MANAGER_CONFIG` or by passing an
explicit config name:

```sh
./scripts/apply-home-manager.sh somnambulist
```

## Full install

Use the full installer when you want the existing macOS setup flow plus the
same stow-free dotfile installation behavior.

```sh
./install.sh
```

On macOS, `install.sh` also applies Home Manager automatically after Nix is
available.

On Linux, set `USE_HOME_MANAGER=1` if you want `install.sh` to apply the Home
Manager stage after Nix is available.

When `install.sh` needs to install Nix, it uses the Determinate installer on
both macOS and Linux.

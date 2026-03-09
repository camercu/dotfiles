# Personal settings and dotfiles

This repository has two layers:

1. `scripts/install-dotfiles.sh` links dotfiles with standard shell tools.
2. Nix manages declarative software and user configuration after Nix is
   installed.

On macOS, `nix-darwin` owns both system state and Home Manager user state. On
Linux, standalone Home Manager remains available for user-level packages and
dotfiles.

## Bootstrap dotfiles

Use the dotfile installer when you need the dotfiles to work before Nix is
available.

```sh
./scripts/install-dotfiles.sh
```

The script links `common/` plus the current OS-specific tree. If it finds an
existing file at a target path, it moves that file into
`~/.dotfiles-backups/<timestamp>/` before linking the repository version.
It also prunes stale managed symlinks when their dotfile entry has been
removed from the active package set.

Use the unlink helper when you want to remove shell-managed dotfile symlinks
that point back into this repository:

```sh
./scripts/uninstall-dotfiles.sh
```

## macOS workflow

On macOS, `nix-darwin` is the source of truth for both machine configuration
and Home Manager user configuration. Use the `nix-darwin` flake to apply
changes:

```sh
make -C ~/.config/nix-darwin update
```

`install.sh` bootstraps Nix with the Determinate installer, links dotfiles,
applies macOS defaults, and installs `nix-darwin` if needed. After that,
`darwin-rebuild` drives both system updates and Home Manager activation.

## Linux workflow

On Linux, standalone Home Manager manages declarative user packages and
dotfiles. Use the helper script after Nix is installed:

```sh
./scripts/apply-home-manager.sh
```

The script auto-detects a matching configuration name from the current host.
You can override that detection with `HOME_MANAGER_CONFIG` or by passing an
explicit config name:

```sh
./scripts/apply-home-manager.sh somnambulist
```

Set `USE_HOME_MANAGER=1` if you want `install.sh` to run the Linux Home
Manager stage automatically after Nix is available.

## Full install

Use the full installer when you want the existing bootstrap flow:

```sh
./install.sh
```

When `install.sh` needs to install Nix, it uses the Determinate installer on
both macOS and Linux.

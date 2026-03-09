# Personal settings and dotfiles

This repository has two layers:

1. `scripts/install-dotfiles.sh` links dotfiles with GNU Stow.
2. The repo-root flake manages declarative software and user configuration
   after Nix is installed.

On macOS, `nix-darwin` owns both system state and Home Manager user state. On
Linux, standalone Home Manager manages declarative user packages.

## Bootstrap dotfiles

Use the dotfile installer when you need the dotfiles to work before Nix is
available.

```sh
./scripts/install-dotfiles.sh
```

The script links `common/` plus the current OS-specific tree via `stow -R`. If
an existing target conflicts, `stow` aborts and prints the conflicting path.
Resolve conflicts by moving/removing the target and rerunning.

Use the unlink helper when you want to remove shell-managed dotfile symlinks
that point back into this repository:

```sh
./scripts/uninstall-dotfiles.sh
```

Use the shell bootstrap when Nix is not available yet or when you need a quick
recovery path. Dotfiles stay managed by Stow even after declarative package
management is enabled.

## macOS workflow

On macOS, `nix-darwin` is the source of truth for both machine configuration
and Home Manager user configuration. The repo root is the canonical flake, and
the nested `~/.config/nix-darwin` flake is only a compatibility wrapper. Use
the `nix-darwin` make target or rebuild directly from the repo root:

```sh
make -C ~/.config/nix-darwin update
```

```sh
darwin-rebuild switch --flake path:$HOME/.dotfiles#TheArk
```

`install.sh` handles OS bootstrap checks and then dispatches to
`scripts/bootstrap-install.zsh`. The zsh installer bootstraps Nix with the
Determinate installer, links dotfiles with Stow, applies macOS defaults, and
installs `nix-darwin` if needed. After that, `darwin-rebuild` drives both
system updates and Home Manager activation.

## Linux workflow

On Linux, standalone Home Manager manages declarative user packages. Dotfiles
continue to be managed by Stow. The repo root is the canonical flake, and the
helper script switches the matching Home Manager configuration:

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
both macOS and Linux. On Linux, `install.sh` can optionally hand off to
standalone Home Manager. On macOS, it hands off to `nix-darwin`, which in turn
applies the embedded Home Manager configuration for that host.

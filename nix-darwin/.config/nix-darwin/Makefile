CONFIG ?= $(shell ../../../../scripts/home-manager-host.sh current-config 2>/dev/null || true)
DOTFILE_DIR ?= $(shell realpath $$HOME/.dotfiles)

.PHONY: update
update:
	nix --extra-experimental-features 'nix-command flakes' flake update --flake path:$(DOTFILE_DIR)
	../../../../scripts/uninstall-dotfiles.sh || printf '%s\n' "warning: bootstrap dotfile cleanup failed before nix-darwin switch" >&2
	sudo darwin-rebuild switch --flake path:$(DOTFILE_DIR)#$(CONFIG)
	../../../../scripts/uninstall-dotfiles.sh || printf '%s\n' "warning: nix-darwin applied but bootstrap dotfile cleanup failed" >&2
	rustup default stable

.PHONY: uninstall
uninstall:
	darwin-uninstaller

.PHONY: install
install:
	../../../../scripts/uninstall-dotfiles.sh || printf '%s\n' "warning: bootstrap dotfile cleanup failed before nix-darwin switch" >&2
	nix run nix-darwin -- switch --flake path:$(DOTFILE_DIR)#$(CONFIG)
	zsh -c 'sudo darwin-rebuild switch --flake path:$(DOTFILE_DIR)#$(CONFIG)'
	../../../../scripts/uninstall-dotfiles.sh || printf '%s\n' "warning: nix-darwin applied but bootstrap dotfile cleanup failed" >&2
	rustup default stable

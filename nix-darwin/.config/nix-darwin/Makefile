DOTFILE_DIR ?= $(shell realpath $$HOME/.dotfiles)
CONFIG ?= $(shell "$(DOTFILE_DIR)/scripts/home-manager-host.sh" current-config 2>/dev/null || "$(DOTFILE_DIR)/scripts/home-manager-host.sh" current-name 2>/dev/null || true)

.PHONY: update
update:
	nix --extra-experimental-features 'nix-command flakes' flake update --flake path:$(DOTFILE_DIR)
	sudo darwin-rebuild switch --flake path:$(DOTFILE_DIR)#$(CONFIG)
	rustup default stable

.PHONY: uninstall
uninstall:
	darwin-uninstaller

.PHONY: install
install:
	nix run nix-darwin -- switch --flake path:$(DOTFILE_DIR)#$(CONFIG)
	zsh -c 'sudo darwin-rebuild switch --flake path:$(DOTFILE_DIR)#$(CONFIG)'
	rustup default stable

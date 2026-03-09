CONFIG ?= $(shell ../../../../scripts/home-manager-host.sh current-config 2>/dev/null || true)
DOTFILE_DIR ?= $(shell realpath $$HOME/.dotfiles)

.PHONY: update
update:
	nix --extra-experimental-features 'nix-command flakes' flake update --flake path:$(DOTFILE_DIR)
	"$(DOTFILE_DIR)/scripts/uninstall-dotfiles.sh" || sh -c '. "$$1/scripts/lib/logging.sh"; warn "$$2"' -- "$(DOTFILE_DIR)" "bootstrap dotfile cleanup failed before nix-darwin switch"
	sudo darwin-rebuild switch --flake path:$(DOTFILE_DIR)#$(CONFIG)
	"$(DOTFILE_DIR)/scripts/uninstall-dotfiles.sh" || sh -c '. "$$1/scripts/lib/logging.sh"; warn "$$2"' -- "$(DOTFILE_DIR)" "nix-darwin applied but bootstrap dotfile cleanup failed"
	rustup default stable

.PHONY: uninstall
uninstall:
	darwin-uninstaller

.PHONY: install
install:
	"$(DOTFILE_DIR)/scripts/uninstall-dotfiles.sh" || sh -c '. "$$1/scripts/lib/logging.sh"; warn "$$2"' -- "$(DOTFILE_DIR)" "bootstrap dotfile cleanup failed before nix-darwin switch"
	nix run nix-darwin -- switch --flake path:$(DOTFILE_DIR)#$(CONFIG)
	zsh -c 'sudo darwin-rebuild switch --flake path:$(DOTFILE_DIR)#$(CONFIG)'
	"$(DOTFILE_DIR)/scripts/uninstall-dotfiles.sh" || sh -c '. "$$1/scripts/lib/logging.sh"; warn "$$2"' -- "$(DOTFILE_DIR)" "nix-darwin applied but bootstrap dotfile cleanup failed"
	rustup default stable

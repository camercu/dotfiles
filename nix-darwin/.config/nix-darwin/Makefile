DOTFILE_DIR ?= $(shell realpath $$HOME/.dotfiles)
CONFIG ?= $(shell "$(DOTFILE_DIR)/scripts/home-manager-host.sh" current-config 2>/dev/null || "$(DOTFILE_DIR)/scripts/home-manager-host.sh" current-name 2>/dev/null || true)

.PHONY: check-config
check-config:
	@if [ -z "$(CONFIG)" ]; then \
		printf '%s\n' "[x] unable to resolve nix-darwin host config from scripts/home-manager-host.sh"; \
		printf '%s\n' "    set HOME_MANAGER_CONFIG or pass CONFIG=<host> to make"; \
		exit 1; \
	fi

.PHONY: update
update: check-config
	nix --extra-experimental-features 'nix-command flakes' flake update --flake path:$(DOTFILE_DIR)
	sudo darwin-rebuild switch --flake path:$(DOTFILE_DIR)#$(CONFIG)
	rustup default stable

.PHONY: uninstall
uninstall:
	darwin-uninstaller

.PHONY: install
install: check-config
	nix run nix-darwin -- switch --flake path:$(DOTFILE_DIR)#$(CONFIG)
	zsh -c 'sudo darwin-rebuild switch --flake path:$(DOTFILE_DIR)#$(CONFIG)'
	rustup default stable

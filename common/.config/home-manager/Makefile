CONFIG ?= $(shell ../../../../scripts/home-manager-host.sh current-config 2>/dev/null || true)
DOTFILE_DIR ?= $(shell realpath $$HOME/.dotfiles)

.PHONY: switch
switch:
	@if [ "$$(uname -s)" = "Darwin" ]; then \
		printf '%s\n' "Use nix-darwin on macOS: make -C ~/.config/nix-darwin update"; \
		exit 1; \
	fi
	../../../../scripts/apply-home-manager.sh "$(CONFIG)"

.PHONY: update
update:
	@if [ "$$(uname -s)" = "Darwin" ]; then \
		printf '%s\n' "Use nix-darwin on macOS: make -C ~/.config/nix-darwin update"; \
		exit 1; \
	fi
	nix --extra-experimental-features 'nix-command flakes' flake update --flake path:$(DOTFILE_DIR)
	../../../../scripts/apply-home-manager.sh "$(CONFIG)"

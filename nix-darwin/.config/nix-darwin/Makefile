DOTFILE_DIR ?= $(shell realpath $$HOME/.dotfiles)
CONFIG ?= $(shell "$(DOTFILE_DIR)/scripts/home-manager-host.sh" current-config 2>/dev/null || "$(DOTFILE_DIR)/scripts/home-manager-host.sh" current-name 2>/dev/null || true)

.PHONY: check-config
check-config:
	@if [ -z "$(CONFIG)" ]; then \
		printf '%s\n' "[x] unable to resolve nix-darwin host config from scripts/home-manager-host.sh"; \
		printf '%s\n' "    set HOME_MANAGER_CONFIG or pass CONFIG=<host> to make"; \
		exit 1; \
	fi

# update: refresh inputs WITHIN the pinned release (nixos-26.05 etc.) and rebuild.
# `nix flake update` bumps every input in flake.lock — nixpkgs, nix-darwin,
# home-manager, and determinate (Determinate Nix itself: nix.enable=false means
# the flake's determinate input drives the Nix daemon, applied on rebuild).
# Do NOT use `nix upgrade-nix`; it is disabled under Determinate Nix.
.PHONY: update
update: check-config
	nix --extra-experimental-features 'nix-command flakes' flake update --flake path:$(DOTFILE_DIR)
	sudo darwin-rebuild switch --flake path:$(DOTFILE_DIR)#$(CONFIG)
	rustup default stable

# upgrade: jump to a NEW NixOS release (the ~6-monthly bump, e.g. 26.05 -> 26.11).
# flake inputs pin a release branch, so `make update` alone never crosses
# releases. This rewrites the four pinned refs in flake.nix, then runs `update`
# to relock + rebuild. Kept separate from `update`/`maintain` on purpose:
# release upgrades carry breaking changes and deserve a deliberate, reviewed run.
# Usage: make upgrade RELEASE=26.11
.PHONY: upgrade
upgrade: check-config
	@if [ -z "$(RELEASE)" ]; then \
		printf '%s\n' "[x] set RELEASE, e.g. make upgrade RELEASE=26.11" >&2; \
		exit 1; \
	fi
	@printf '%s\n' "[*] bumping nixpkgs/nixpkgsDarwin/nix-darwin/home-manager to release $(RELEASE)"
	REL='$(RELEASE)' perl -pi -e 's{(nixos/nixpkgs/nixos-)\d+\.\d+}{$$1$$ENV{REL}}g; s{(NixOS/nixpkgs/nixpkgs-)\d+\.\d+(-darwin)}{$$1$$ENV{REL}$$2}g; s{(home-manager/release-)\d+\.\d+}{$$1$$ENV{REL}}g; s{(nix-darwin/nix-darwin-)\d+\.\d+}{$$1$$ENV{REL}}g;' "$(DOTFILE_DIR)/flake.nix"
	$(MAKE) update

.PHONY: uninstall
uninstall:
	darwin-uninstaller

.PHONY: install
install: check-config
	nix run nix-darwin -- switch --flake path:$(DOTFILE_DIR)#$(CONFIG)
	zsh -c 'sudo darwin-rebuild switch --flake path:$(DOTFILE_DIR)#$(CONFIG)'
	rustup default stable

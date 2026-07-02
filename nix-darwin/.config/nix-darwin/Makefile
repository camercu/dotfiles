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
	@git ls-remote --heads https://github.com/NixOS/nixpkgs "nixos-$(RELEASE)" 2>/dev/null | grep -q . \
		|| { printf '%s\n' "[x] release $(RELEASE) is not cut yet (no nixos-$(RELEASE) branch). Run 'make check-release'." >&2; exit 1; }
	@printf '%s\n' "[*] bumping nixpkgs/nixpkgsDarwin/nix-darwin/home-manager to release $(RELEASE)"
	REL='$(RELEASE)' perl -pi -e 's{(nixos/nixpkgs/nixos-)\d+\.\d+}{$$1$$ENV{REL}}g; s{(NixOS/nixpkgs/nixpkgs-)\d+\.\d+(-darwin)}{$$1$$ENV{REL}$$2}g; s{(home-manager/release-)\d+\.\d+}{$$1$$ENV{REL}}g; s{(nix-darwin/nix-darwin-)\d+\.\d+}{$$1$$ENV{REL}}g;' "$(DOTFILE_DIR)/flake.nix"
	$(MAKE) update

# check-release: is the NEXT NixOS release cut and ready to upgrade to?
# NixOS releases twice a year as YY.MM (.05 = May, .11 = Nov). A release is
# usable here only once ALL four pinned inputs have branched. Reports the next
# release and whether each branch exists yet (read-only; no admin needed).
.PHONY: check-release
check-release:
	@cur=$$(grep -oE 'nixos-[0-9]+\.[0-9]+' "$(DOTFILE_DIR)/flake.nix" | head -1 | sed 's/nixos-//'); \
	yy=$${cur%%.*}; mm=$${cur##*.}; \
	if [ "$$mm" = "05" ]; then next="$$yy.11"; else next="$$((yy + 1)).05"; fi; \
	printf '[*] current release: %s   next: %s\n' "$$cur" "$$next"; \
	ready=1; \
	for spec in \
		"NixOS/nixpkgs:nixos-$$next" \
		"NixOS/nixpkgs:nixpkgs-$$next-darwin" \
		"nix-community/home-manager:release-$$next" \
		"nix-darwin/nix-darwin:nix-darwin-$$next"; do \
		repo=$${spec%%:*}; br=$${spec#*:}; \
		if git ls-remote --heads "https://github.com/$$repo" "$$br" 2>/dev/null | grep -q .; then \
			printf '  [+] %s\n' "$$br"; \
		else \
			printf '  [ ] %s (not cut yet)\n' "$$br"; ready=0; \
		fi; \
	done; \
	if [ "$$ready" = 1 ]; then \
		printf '[+] %s is available -- run: make upgrade RELEASE=%s\n' "$$next" "$$next"; \
	else \
		printf '[!] %s not fully cut yet; staying on %s\n' "$$next" "$$cur"; \
	fi

.PHONY: uninstall
uninstall:
	darwin-uninstaller

.PHONY: install
install: check-config
	nix run nix-darwin -- switch --flake path:$(DOTFILE_DIR)#$(CONFIG)
	zsh -c 'sudo darwin-rebuild switch --flake path:$(DOTFILE_DIR)#$(CONFIG)'
	rustup default stable

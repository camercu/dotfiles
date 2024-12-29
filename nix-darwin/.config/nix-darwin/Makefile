.PHONY: sync
sync:
	darwin-rebuild switch --flake $$(realpath ~/.config/nix-darwin)

.PHONY: update
update:
	nix flake update --flake $$(realpath ~/.config/nix-darwin)
	nix-channel --update darwin

.PHONY: uninstall
uninstall:
	darwin-uninstaller

.PHONY: install
install:
	nix run nix-darwin -- switch --flake $$(realpath ~/.config/nix-darwin)
	zsh -c 'darwin-rebuild switch --flake $(realpath ~/.config/nix-darwin)'


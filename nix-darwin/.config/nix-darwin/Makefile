.PHONY: update
update:
	nix --extra-experimental-features 'nix-command flakes' flake update --flake $$(realpath ~/.config/nix-darwin)
	sudo darwin-rebuild switch --flake $$(realpath ~/.config/nix-darwin)
	rustup default stable

.PHONY: uninstall
uninstall:
	darwin-uninstaller

.PHONY: install
install:
	nix run nix-darwin -- switch --flake $$(realpath ~/.config/nix-darwin)
	zsh -c 'sudo darwin-rebuild switch --flake $(realpath ~/.config/nix-darwin)'
	rustup default stable


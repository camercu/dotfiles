.PHONY: sync
sync:
	home-manager switch --impure --flake ".#${$(hostname)%.*}"

.PHONY: update
update:
	nix-channel --update
	nix flake update
	home-manager switch --impure --flake ".#${$(hostname)%.*}"

.PHONY: install
install:
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install

.PHONY: uninstall
uninstall:
	nix run home-manager/release-24.11 -- uninstall


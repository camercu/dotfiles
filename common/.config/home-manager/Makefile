CONFIG ?= $(shell sh -c 'if [ -n "$$HOME_MANAGER_CONFIG" ]; then printf "%s" "$$HOME_MANAGER_CONFIG"; elif [ "$$(uname -s)" = "Darwin" ] && command -v scutil >/dev/null 2>&1; then scutil --get ComputerName | tr "[:upper:]" "[:lower:]" | tr -cd "[:alnum:]_-"; else hostname -s | tr "[:upper:]" "[:lower:]" | tr -cd "[:alnum:]_-"; fi')

.PHONY: switch
switch:
	../../../../scripts/apply-home-manager.sh "$(CONFIG)"

.PHONY: update
update:
	nix --extra-experimental-features 'nix-command flakes' flake update --flake .
	../../../../scripts/apply-home-manager.sh "$(CONFIG)"

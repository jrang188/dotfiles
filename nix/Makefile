# Careful about copy/pasting, Makefiles want tabs!
.PHONY: default darwin nixos ubuntu clean update

default:
	@echo "Please specify a target:"
	@echo "  make darwin  - Rebuild Darwin configuration"
	@echo "  make nixos   - Rebuild NixOS configuration"
	@echo "  make ubuntu  - Rebuild Ubuntu Home Manager configuration"
	@echo "  make clean   - Collect garbage"
	@echo "  make update  - Update flake inputs"

darwin:
	sudo darwin-rebuild switch --flake .#Sterling-MBP

nixos:
	sudo nixos-rebuild switch --flake .#nixos-wsl

ubuntu:
	home-manager switch --flake .#sirwayne

clean:
	nix-collect-garbage -d

update:
	nix flake update

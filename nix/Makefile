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
	darwin-rebuild switch --flake .#Sterling-MBP

nixos:
	nixos-rebuild switch --flake .#your-nixos-host

ubuntu:
	home-manager switch --flake .#sirwayne

clean:
	nix-collect-garbage -d

update:
	nix flake update

# Careful about copy/pasting, Makefiles want tabs!
.PHONY: default darwin nixos clean update

default:
	@echo "Please specify a target:"
	@echo "  make darwin  - Rebuild Darwin configuration"
	@echo "  make nixos   - Rebuild NixOS configuration"
	@echo "  make clean   - Collect garbage"
	@echo "  make update  - Update flake inputs"

darwin:
	darwin-rebuild switch --flake .#Sterling-MBP

nixos:
	nixos-rebuild switch --flake .#your-nixos-host

clean:
	nix-collect-garbage -d

update:
	nix flake update

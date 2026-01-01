# Careful about copy/pasting, Makefiles want tabs!
.PHONY: default darwin nixos ubuntu clean update

default:
	@echo "Please specify a target:"
	@echo "  make darwin  - Rebuild Darwin configuration"
	@echo "  make nixos   - Rebuild NixOS configuration"
	@echo "  make wsl     - Rebuild NixOS WSL Configuration"
	@echo "  make ubuntu  - Rebuild Ubuntu Home Manager configuration"
	@echo "  make clean   - Collect garbage"
	@echo "  make update  - Update flake inputs"

darwin:
	nh darwin switch . -H Sterling-MBP

wsl:
	nh os switch . -H wsl

nixos:
	nh os switch . -H kirby

ubuntu:
	home-manager switch --flake .#sirwayne

clean:
	nh clean all
	# nix-collect-garbage -d

update:
	nix flake update

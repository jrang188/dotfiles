# Careful about copy/pasting, Makefiles want tabs!
.PHONY: default darwin nixos ubuntu clean update lint format fmt

default:
	@echo "Please specify a target:"
	@echo "  make darwin  - Rebuild Darwin configuration"
	@echo "  make nixos   - Rebuild NixOS configuration"
	@echo "  make wsl     - Rebuild NixOS WSL Configuration"
	@echo "  make ubuntu  - Rebuild Ubuntu Home Manager configuration"
	@echo "  make clean   - Collect garbage"
	@echo "  make update  - Update flake inputs"
	@echo "  make lint    - Lint Nix files with statix"
	@echo "  make format  - Format Nix files with nixfmt-tree"
	@echo "  make fmt     - Alias for format"

darwin:
	nh darwin switch --ask . -H Sterling-MBP

wsl:
	nh os switch --ask . -H wsl

nixos:
	nh os switch --ask . -H kirby

ubuntu:
	home-manager switch --flake .#sirwayne

clean:
	nh clean all

update:
	nix flake update

lint:
	statix check .

format:
	nix fmt

fmt: format

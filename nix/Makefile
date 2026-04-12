# Careful about copy/pasting, Makefiles want tabs!
.PHONY: default darwin nixos ubuntu clean update lint format fmt

default:
	@echo "Please specify a target:"
	@echo "  make darwin  - Rebuild Darwin configuration"
	@echo "  make nixos   - Rebuild NixOS configuration"
	@echo "  make clean   - Collect garbage"
	@echo "  make update  - Update flake inputs"
	@echo "  make lint    - Lint Nix files with statix"
	@echo "  make format  - Format Nix files with nixfmt-tree"

darwin:
	nh darwin switch . -H Sterling-MBP

nixos:
	nh os switch . -H kirby

clean:
	nh clean all

update:
	nix flake update

lint:
	statix check .

format:
	nix fmt

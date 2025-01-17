# Careful about copy/pasting, Makefiles want tabs!
OS := $(shell uname)

.PHONY: deploy
deploy:
ifeq ($(OS),Darwin)
	@echo "Deploying on macOS"
	darwin-rebuild switch --flake .#Sterling-MBP
else ifeq ($(OS),Linux)
	@echo "Deploying on Linux"
	nixos-rebuild switch --flake .#NixOS-WSL
else
	@echo "Unsupported OS: $(OS)"

.PHONY: clean
clean:
	nix-collect-garbage -d

.PHONY: update
update:
	nix flake update
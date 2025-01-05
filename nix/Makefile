# Careful about copy/pasting, Makefiles want tabs!
.PHONY: deploy
deploy:
	sudo darwin-rebuild switch --flake .

.PHONY: clean
clean:
	nix-collect-garbage -d

.PHONY: update
update:
	nix flake update
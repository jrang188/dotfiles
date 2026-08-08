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

# `nh clean all` calls `nix-collect-garbage` which chmods store paths before
# deleting. On macOS 26.x (Tahoe), `com.apple.macl` (stamped on any .app
# bundle that has been launched from /nix/store) is a TCC-protected xattr that
# not even root can strip with `xattr -d`. The chmod hits EPERM, the whole GC
# aborts with "0 store paths deleted".
#
# Workaround: prune stale .app paths (referrers == 0 or orphan) via direct
# `rm -rf`. Root can unlink entries from /nix/store without chmod'ing the
# files, which sidesteps the SACL. Live paths are never touched because
# their referrer count > 0.
#
# Do NOT replace this with `xattr -dr com.apple.macl …` — that was the
# pre-Tahoe approach and is permanently broken on macOS 26.x.
clean:
	@for p in $$(find /nix/store -maxdepth 4 -name "*.app" -type d 2>/dev/null); do \
	  if ! refs=$$(nix-store --query --referrers "$$p" 2>/dev/null); then \
	    echo "pruning orphan app: $$p"; \
	    sudo rm -rf "$$p" || echo "warning: failed to prune $$p" >&2; \
	    continue; \
	  fi; \
	  real=$$(printf '%s\n' "$$refs" | grep -v -F "$$p" | grep -c .); \
	  if [ "$$real" = "0" ]; then \
	    echo "pruning stale app: $$p (0 non-self referrers)"; \
	    sudo rm -rf "$$p" || echo "warning: failed to prune $$p" >&2; \
	  else \
	    echo "skipping live app: $$p ($$real referrer(s))"; \
	  fi; \
	done
	nh clean all

update:
	nix flake update

lint:
	statix check .

format:
	nix fmt

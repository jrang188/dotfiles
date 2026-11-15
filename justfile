# Task runner for this repo. Run `just` from the repo root or any
# subdirectory; every recipe executes in nix/.
set working-directory := "nix"
set shell := ["bash", "-c"]

# List available recipes
default:
    @just --list

# Rebuild Darwin configuration (Sterling-MBP)
darwin:
    nh darwin switch . -H Sterling-MBP

# Rebuild NixOS configuration (kirby)
nixos:
    nh os switch . -H kirby

# `nh clean all` calls `nix-collect-garbage`, which chmods store paths before
# deleting. On macOS 26.x (Tahoe), `com.apple.macl` (stamped on any .app
# bundle that has been launched from /nix/store) is a TCC-protected xattr that
# not even root can strip with `xattr -d`. The chmod hits EPERM and the whole
# GC aborts with "0 store paths deleted".
#
# Workaround: prune stale .app paths (referrers == 0 or orphan) via direct
# `rm -rf`. Root can unlink entries from /nix/store without chmod'ing the
# files, which sidesteps the SACL. Live paths are never touched because their
# referrer count > 0.
#
# Do NOT replace this with `xattr -dr com.apple.macl …` — that was the
# pre-Tahoe approach and is permanently broken on macOS 26.x.

# Prune stale .app bundles, then collect garbage
clean:
    #!/usr/bin/env bash
    for p in $(find /nix/store -maxdepth 4 -name "*.app" -type d 2>/dev/null); do
        if ! refs=$(nix-store --query --referrers "$p" 2>/dev/null); then
            echo "pruning orphan app: $p"
            sudo rm -rf "$p" || echo "warning: failed to prune $p" >&2
            continue
        fi
        real=$(printf '%s\n' "$refs" | grep -v -F "$p" | grep -c .)
        if [ "$real" = "0" ]; then
            echo "pruning stale app: $p (0 non-self referrers)"
            sudo rm -rf "$p" || echo "warning: failed to prune $p" >&2
        else
            echo "skipping live app: $p ($real referrer(s))"
        fi
    done
    nh clean all

# Update flake inputs
update:
    nix flake update

# Lint Nix files with statix
lint:
    statix check .

# Format Nix files with nixfmt-tree
format:
    nix fmt

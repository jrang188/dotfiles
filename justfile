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
# Workaround: ask nix which store paths are actually dead (`--print-dead`), and
# `rm -rf` those that contain an .app bundle before running the GC. Root can
# unlink entries from /nix/store without chmod'ing the files, which sidesteps
# the SACL. Liveness comes from nix itself, so live paths are never touched,
# and whole paths are removed so no half-deleted store path is left behind.
#
# Do NOT replace this with `xattr -dr com.apple.macl …` — that was the
# pre-Tahoe approach and is permanently broken on macOS 26.x.

# Prune dead .app-bearing store paths, then collect garbage
clean:
    #!/usr/bin/env bash
    dead=$(mktemp)
    trap 'rm -f "$dead"' EXIT

    if ! nix-store --gc --print-dead > "$dead"; then
        echo "error: could not compute dead store paths; refusing to prune" >&2
        exit 1
    fi

    failed=0
    while IFS= read -r app; do
        path=${app#/nix/store/}
        path=/nix/store/${path%%/*}
        if ! grep -qxF "$path" "$dead"; then
            continue
        fi
        if sudo rm -rf "$path"; then
            echo "pruned dead path: $path"
        else
            echo "warning: failed to prune $path" >&2
            failed=1
        fi
    done < <(find /nix/store -maxdepth 4 -name "*.app" -type d 2>/dev/null)

    if [ "$failed" != 0 ]; then
        echo "error: pruning failed; aborting before GC (it would hit com.apple.macl)" >&2
        exit 1
    fi

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

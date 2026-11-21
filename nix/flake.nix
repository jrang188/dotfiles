{
  description = "My Nix System Configurations";

  inputs = {
    # Main nixpkgs for NixOS (requires NixOS tests)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Darwin-specific nixpkgs (faster, no NixOS tests required).
    #
    # TEMPORARILY pinned to the commit that fixes swift-collections on Darwin:
    # NixOS/nixpkgs@5b0748384e "swiftPackages.swift-collections: ensure there is
    # enough room for install names on Darwin" (2026-11-20). The pinned channel
    # rev (b758f162, 2026-11-20 06:23) links the SWIFT dylibs without header
    # padding, so `install_name_tool` aborts with "larger updated load commands
    # do not fit" and takes down swift-collections → swiftpm → swift → dockutil
    # → mac-app-util, i.e. the entire Darwin system build.
    #
    # A host-level `nixpkgs.overlays` entry cannot fix this: mac-app-util builds
    # its package from its own evaluation of this input (`self.packages` in its
    # darwinModules/homeManagerModules), not from our overlaid `pkgs`. Pinning
    # the input is the only lever.
    #
    # A plain `nix flake update` did NOT fix this: nixpkgs-unstable's head was
    # still 9996594 (2026-11-20 15:12 UTC), which predates the fix commit.
    #
    # Revert to `github:NixOS/nixpkgs/nixpkgs-unstable` once that branch contains
    # 5b0748384e, then `nix flake update nixpkgs-darwin`. Check with:
    #   curl -s https://raw.githubusercontent.com/NixOS/nixpkgs/nixpkgs-unstable/\
    #   pkgs/development/compilers/swift/by-name/sw/swift-collections/package.nix \
    #   | grep NIX_LDFLAGS
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/5b0748384e8e2011c7c3fb508e01c3da0a27def8";
    # Stable references for each system type
    nixpkgs-stable-nixos.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      # Follow Darwin nixpkgs (the SBCL 2.6.0 build failure was
      # closed as cannot-repro; the pin was removed 2026-07).
      inputs.nixpkgs.follows = "nixpkgs-darwin";
      # cl-nix-lite's flake-parts pins `nix-community/nixpkgs.lib` at a
      # 2025-12 rev whose lib/trivial.nix and lib/options.nix still use `or`
      # as an identifier, so Lix warns "using or as an identifier is
      # deprecated" on every Darwin evaluation. Neither mac-app-util nor
      # cl-nix-lite has moved past it upstream, so point that transitive input
      # at Darwin nixpkgs (which quotes `"or"`); flake-parts only needs
      # `nixpkgs-lib.lib`, which nixpkgs also exports.
      inputs.cl-nix-lite.inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-darwin";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Home Manager for Darwin uses Darwin-specific nixpkgs
    home-manager-darwin = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    lanzaboote = {
      # v1.2.0 (2026-09-26) over v1.1.0: its rust-overlay pin (1fb104a) uses
      # `stdenv.hostPlatform.is*` where 8534567 still used the deprecated
      # `stdenv.isLinux`/`isDarwin`, which was the last source of Lix's
      # `stdenv.is… is deprecated` warnings on kirby. The 1.2.0 Measured Boot
      # changes (PCR4 locking, 8→4 generations) only affect
      # `boot.lanzaboote.measuredBoot`, which kirby does not enable.
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    # HEX local-first voice dictation. Linux-only (x86_64-/aarch64-linux), so
    # only kirby consumes it. Its nixpkgs must follow kirby's: upstream warns
    # that a Hex built against its own older pin can link an older glibc than
    # the graphics drivers need, find no Vulkan adapter and never open a
    # window (see upstream docs/nix.md).
    hex = {
      url = "github:anomalyco/hex";
      inputs.nixpkgs.follows = "nixpkgs";
      # Hex declares a home-manager input but never references it in its
      # outputs; follow ours so the lock file carries no second Home Manager.
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs:
    let
      # Common variables
      username = "sirwayne";
      darwinSystem = "aarch64-darwin";
      nixosSystem = "x86_64-linux";

      # Helper function to get the correct stable nixpkgs input based on system
      getStableNixpkgs =
        system:
        if system == darwinSystem then inputs.nixpkgs-stable-darwin else inputs.nixpkgs-stable-nixos; # default to nixos stable

      # Helper function to get stable packages (system-specific)
      mkStablePkgs = { system }: (getStableNixpkgs system).legacyPackages.${system};

      # Helper function to create specialArgs
      mkSpecialArgs =
        {
          hostname,
          system,
          extraArgs ? { },
        }:
        inputs
        // {
          inherit username hostname inputs;
          pkgs-stable = mkStablePkgs { inherit system; };
        }
        // extraArgs;

      # Helper function to create home-manager configuration
      mkHomeManagerConfig =
        {
          hostname,
          system,
          homeImports,
          extraArgs ? { },
        }:
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = mkSpecialArgs { inherit hostname system extraArgs; };
            # Rename clobbered paths to <name>.backup instead of failing,
            # so home-manager can replace a previously-managed file with a
            # directory (or vice versa) without manual intervention.
            backupFileExtension = "backup";
            users.${username} = {
              imports = homeImports;
            };
          };
        };

      # Helper function to create system configurations
      mkSystem =
        {
          hostname,
          system,
          modules,
          homeImports,
          extraArgs ? { },
        }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = mkSpecialArgs { inherit hostname system extraArgs; };
          modules = modules ++ [
            inputs.home-manager.nixosModules.home-manager
            (mkHomeManagerConfig {
              inherit
                hostname
                system
                homeImports
                extraArgs
                ;
            })
          ];
        };

      # Helper function to create Darwin configurations
      mkDarwin =
        {
          hostname,
          modules,
          homeImports,
          extraArgs ? { },
        }:
        inputs.darwin.lib.darwinSystem {
          system = darwinSystem;
          specialArgs = mkSpecialArgs {
            inherit hostname;
            system = darwinSystem;
            inherit extraArgs;
          };
          modules = modules ++ [
            inputs.mac-app-util.darwinModules.default
            inputs.home-manager-darwin.darwinModules.home-manager
            (mkHomeManagerConfig {
              inherit hostname;
              system = darwinSystem;
              inherit homeImports extraArgs;
            })
            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                # Install Homebrew under the default prefix
                enable = true;

                # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                enableRosetta = true;

                # User owning the Homebrew prefix
                user = username;

                # Automatically migrate existing Homebrew installations
                autoMigrate = true;
              };
            }
          ];
        };
    in
    {
      # Darwin configuration
      darwinConfigurations."Sterling-MBP" = mkDarwin {
        hostname = "Sterling-MBP";
        modules = [ ./hosts/darwin/Sterling-MBP ];
        homeImports = [
          ./home
          ./home/darwin
          inputs.mac-app-util.homeManagerModules.default
        ];
      };

      # NixOS configuration with secure boot
      nixosConfigurations."kirby" = mkSystem {
        hostname = "kirby-machine";
        system = nixosSystem;
        modules = [
          ./hosts/nixos/kirby
          inputs.lanzaboote.nixosModules.lanzaboote
        ];
        homeImports = [
          ./home
          ./home/nixos/kirby
        ];
        extraArgs = {
          inherit (inputs)
            zen-browser
            llm-agents
            ;
        };
      };

      formatter = {
        ${darwinSystem} = inputs.nixpkgs-darwin.legacyPackages.${darwinSystem}.nixfmt-tree;
        ${nixosSystem} = inputs.nixpkgs.legacyPackages.${nixosSystem}.nixfmt-tree;
      };
    };
}

{
  description = "My Nix System Configurations";

  inputs = {
    # Main nixpkgs for NixOS (requires NixOS tests)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Darwin-specific nixpkgs (faster, no NixOS tests required)
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Stable references for each system type
    nixpkgs-stable-nixos.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Don't follow nixpkgs to avoid SBCL 2.6.0 build failure
    # See: https://github.com/hraban/mac-app-util/issues/42
    mac-app-util = {
      url = "github:hraban/mac-app-util";
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
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    # Upstream Hyprland 0.56.0 + matching hy3 hl0.56.0.1. Use direct flakes (not
    # nixpkgs) so the hy3 build is ABI-locked to this exact Hyprland via `follows`.
    # Bump both together. nixpkgs still ships 0.54.3, so the upstream pin is
    # required to keep ABI alignment (nixpkgs' hyprlandPlugins.hy3 already moved
    # past the nixpkgs hyprland and is unusable against the in-tree version).
    #
    # hypr* transitive deps: pinned to upstream tags. The hyprland flake's
    # transitive inputs default to the moving HEAD of hyprwm/*, which is older
    # than the latest tag and is ABI-mismatched with Hyprland 0.56.0 (CMake's
    # pkg-config check rejects them). Drop the overrides once nixpkgs catches
    # up to versions new enough to satisfy Hyprland's >= constraints.
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1&ref=refs/tags/v0.56.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        hyprutils.follows = "hyprutils";
        aquamarine.follows = "aquamarine";
        hyprgraphics.follows = "hyprgraphics";
        hyprwire.follows = "hyprwire";
        hyprland-protocols.follows = "hyprland-protocols";
      };
    };
    hy3 = {
      url = "github:outfoxxed/hy3?ref=hl0.56.0.1";
      inputs.hyprland.follows = "hyprland";
    };
    hyprutils = {
      url = "github:hyprwm/hyprutils?ref=v0.14.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aquamarine = {
      url = "github:hyprwm/aquamarine?ref=v0.13.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        hyprutils.follows = "hyprutils";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
      };
    };
    hyprgraphics = {
      url = "github:hyprwm/hyprgraphics?ref=v0.5.1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        hyprutils.follows = "hyprutils";
      };
    };
    hyprwire = {
      url = "github:hyprwm/hyprwire?ref=v0.3.1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        hyprutils.follows = "hyprutils";
      };
    };
    hyprwayland-scanner = {
      url = "github:hyprwm/hyprwayland-scanner?ref=v0.4.6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-protocols = {
      url = "github:hyprwm/hyprland-protocols?ref=v0.7.0";
      inputs.nixpkgs.follows = "nixpkgs";
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
            hyprland
            hy3
            ;
        };
      };

      formatter = {
        ${darwinSystem} = inputs.nixpkgs-darwin.legacyPackages.${darwinSystem}.nixfmt-tree;
        ${nixosSystem} = inputs.nixpkgs.legacyPackages.${nixosSystem}.nixfmt-tree;
      };
    };
}

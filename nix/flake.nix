{
  description = "My Nix System Configurations";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.2511.*";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: Uncomment this and remove the inputs below when mac-app-util is fixed
    # mac-app-util = {
    #   url = "github:hraban/mac-app-util";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.cl-nix-lite.url = "github:r4v3n6101/cl-nix-lite/url-fix";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.2511.*";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    lanzaboote = {
      url = "https://flakehub.com/f/nix-community/lanzaboote/0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      # Common variables
      username = "sirwayne";
      darwinSystem = "aarch64-darwin";
      nixosSystem = "x86_64-linux";

      # Helper function to create unstable packages
      mkUnstablePkgs =
        { system, nixpkgs-unstable }:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
          config.allowBroken = true;
        };

      # Helper function to create specialArgs
      mkSpecialArgs =
        {
          hostname,
          system,
          extraArgs ? { },
        }:
        inputs
        // {
          inherit username hostname;
          pkgs-unstable = mkUnstablePkgs {
            inherit system;
            inherit (inputs) nixpkgs-unstable;
          };
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
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = mkSpecialArgs { inherit hostname system extraArgs; };
          home-manager.users.${username} = {
            imports = homeImports;
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
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = mkSpecialArgs { inherit hostname system extraArgs; };
          modules = modules ++ [
            inputs.determinate.nixosModules.default
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
            { nix.enable = false; } # We want to use determinate nix
            inputs.mac-app-util.darwinModules.default
            inputs.home-manager.darwinModules.home-manager
            (mkHomeManagerConfig {
              inherit hostname;
              system = darwinSystem;
              inherit homeImports extraArgs;
            })
          ];
        };

      # Helper function to create Home Manager configurations
      mkHome =
        {
          hostname,
          modules,
          extraArgs ? { },
        }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.${nixosSystem};
          extraSpecialArgs = mkSpecialArgs {
            inherit hostname;
            system = nixosSystem;
            inherit extraArgs;
          };
          inherit modules;
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

      # WSL NixOS configuration
      nixosConfigurations."wsl" = mkSystem {
        hostname = "nixos-wsl";
        system = nixosSystem;
        modules = [
          inputs.nixos-wsl.nixosModules.default
          ./hosts/nixos/wsl
        ];
        homeImports = [
          ./home
          ./home/nixos/wsl
        ];
      };

      # Ubuntu WSL Configuration
      homeConfigurations.${username} = mkHome {
        hostname = "GHOST-MACHINE";
        modules = [
          ./home
          ./home/ubuntu
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
        extraArgs = { inherit (inputs) zen-browser; };
      };

      formatter = {
        ${darwinSystem} = nixpkgs.legacyPackages.${darwinSystem}.nixfmt-rfc-style;
        ${nixosSystem} = nixpkgs.legacyPackages.${nixosSystem}.nixfmt-rfc-style;
      };
    };
}

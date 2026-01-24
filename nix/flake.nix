{
  description = "My Nix System Configurations";

  inputs = {
    # Main nixpkgs pinned to unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Stable references for each system type
    nixpkgs-stable-nixos.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    darwin = {
      url = "github:LnL7/nix-darwin";
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
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      # Common variables
      username = "sirwayne";
      darwinSystem = "aarch64-darwin";
      nixosSystem = "x86_64-linux";

      # Helper function to get the correct stable nixpkgs input based on system
      getStableNixpkgs = system:
        if system == darwinSystem then
          inputs.nixpkgs-stable-darwin
        else
          inputs.nixpkgs-stable-nixos; # default to nixos stable

      # Helper function to get stable packages (system-specific)
      mkStablePkgs = { system }:
        (getStableNixpkgs system).legacyPackages.${system};

      # Helper function to create specialArgs
      mkSpecialArgs = { hostname, system, extraArgs ? { }, }:
        inputs // {
          inherit username hostname;
          pkgs-stable = mkStablePkgs { inherit system; };
        } // extraArgs;

      # Helper function to create home-manager configuration
      mkHomeManagerConfig =
        { hostname, system, homeImports, extraArgs ? { }, }: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs =
              mkSpecialArgs { inherit hostname system extraArgs; };
            users.${username} = { imports = homeImports; };
          };
        };

      # Helper function to create system configurations
      mkSystem = { hostname, system, modules, homeImports, extraArgs ? { }, }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = mkSpecialArgs { inherit hostname system extraArgs; };
          modules = modules ++ [
            inputs.determinate.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            (mkHomeManagerConfig {
              inherit hostname system homeImports extraArgs;
            })
          ];
        };

      # Helper function to create Darwin configurations
      mkDarwin = { hostname, modules, homeImports, extraArgs ? { }, }:
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
      mkHome = { hostname, modules, extraArgs ? { }, }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.${nixosSystem};
          extraSpecialArgs = mkSpecialArgs {
            inherit hostname;
            system = nixosSystem;
            inherit extraArgs;
          };
          inherit modules;
        };

    in {
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
        modules = [ inputs.nixos-wsl.nixosModules.default ./hosts/nixos/wsl ];
        homeImports = [ ./home ./home/nixos/wsl ];
      };

      # Ubuntu WSL Configuration
      homeConfigurations.${username} = mkHome {
        hostname = "GHOST-MACHINE";
        modules = [ ./home ./home/ubuntu ];
      };

      # NixOS configuration with secure boot
      nixosConfigurations."kirby" = mkSystem {
        hostname = "kirby-machine";
        system = nixosSystem;
        modules =
          [ ./hosts/nixos/kirby inputs.lanzaboote.nixosModules.lanzaboote ];
        homeImports = [ ./home ./home/nixos/kirby ];
        extraArgs = { inherit (inputs) zen-browser; };
      };

      formatter = {
        ${darwinSystem} = nixpkgs.legacyPackages.${darwinSystem}.nixfmt;
        ${nixosSystem} = nixpkgs.legacyPackages.${nixosSystem}.nixfmt;
      };
    };
}

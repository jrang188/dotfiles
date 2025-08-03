{
  description = "My Nix System Configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/release-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    inputs = {
      zen-browser.url = "github:0xc000022070/zen-browser-flake";
    };
  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      darwin,
      mac-app-util,
      nixos-wsl,
      home-manager,
      ...
    }:
    let
      username = "sirwayne";
      darwinSystem = "aarch64-darwin";
      nixosSystem = "x86_64-linux";
    in
    {
      darwinConfigurations."Sterling-MBP" = darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = inputs // {
          inherit username;
          hostname = "Sterling-MBP";
          pkgs-unstable = import nixpkgs-unstable {
            # Refer to the `system` parameter from
            # the outer scope recursively
            system = darwinSystem;
            # To use Chrome, we need to allow the
            # installation of non-free software.
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/darwin/Sterling-MBP

          mac-app-util.darwinModules.default

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = inputs // {
              inherit username;
              hostname = "Sterling-MBP";
              pkgs-unstable = import nixpkgs-unstable {
                # Refer to the `system` parameter from
                # the outer scope recursively
                system = darwinSystem;
                # To use Chrome, we need to allow the
                # installation of non-free software.
                config.allowUnfree = true;
              };
            };
            home-manager.users.${username} = {
              imports = [
                ./home
                ./home/darwin
                mac-app-util.homeManagerModules.default
              ];
            };
          }
        ];
      };

      # WSL NixOS configuration
      nixosConfigurations."wsl" = nixpkgs.lib.nixosSystem {
        system = nixosSystem;
        specialArgs = inputs // {
          inherit username;
          hostname = "nixos-wsl";
          pkgs-unstable = import nixpkgs-unstable {
            # Refer to the `system` parameter from
            # the outer scope recursively
            system = nixosSystem;
            # To use Chrome, we need to allow the
            # installation of non-free software.
            config.allowUnfree = true;
          };
        };
        modules = [
          nixos-wsl.nixosModules.default
          ./hosts/nixos/wsl
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = inputs // {
              inherit username;
              hostname = "nixos-wsl";
              pkgs-unstable = import nixpkgs-unstable {
                # Refer to the `system` parameter from
                # the outer scope recursively
                system = nixosSystem;
                # To use Chrome, we need to allow the
                # installation of non-free software.
                config.allowUnfree = true;
              };
            };
            home-manager.users.${username} = {
              imports = [
                ./home
                ./home/nixos/wsl
              ];
            };
          }
        ];
      };

      # Ubuntu WSL Configuration
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = inputs // {
          inherit username;
          hostname = "GHOST-MACHINE";
          pkgs-unstable = import nixpkgs-unstable {
            # Refer to the `system` parameter from
            # the outer scope recursively
            system = nixosSystem;
            # To use Chrome, we need to allow the
            # installation of non-free software.
            config.allowUnfree = true;
          };
        };
        modules = [
          ./home
          ./home/ubuntu
        ];
      };

      # AND FINALLY, THE OG, NIXOS
      nixosConfigurations."kirby" = nixpkgs.lib.nixosSystem {
        system = nixosSystem;
        specialArgs = inputs // {
          inherit username;
          hostname = "kirby-machine";
          pkgs-unstable = import nixpkgs-unstable {
            system = nixosSystem;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/nixos/kirby
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = inputs // {
              inherit username;
              hostname = "kirby-machine";
              pkgs-unstable = import nixpkgs-unstable {
                system = nixosSystem;
                config.allowUnfree = true;
              };
            };
            home-manager.users.${username} = {
              imports = [
                ./home
                ./home/nixos/kirby
              ];
            };
          }
        ];
      };

      formatter = {
        ${darwinSystem} = nixpkgs.legacyPackages.${darwinSystem}.nixfmt;
        ${nixosSystem} = nixpkgs.legacyPackages.${nixosSystem}.nixfmt;
      };
    };
}

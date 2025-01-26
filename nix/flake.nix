{
  description = "My Nix System Configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
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
      darwin,
      nixos,
      home-manager,
      ...
    }:
    let
      username = "sirwayne";
      darwinSystem = "aarch64-darwin";
      nixosSystem = "x86_64-linux"; # adjust according to your needs
    in
    {
      darwinConfigurations."Sterling-MBP" = darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = inputs // {
          inherit username;
          hostname = "Sterling-MBP";
        };
        modules = [
          ./hosts/darwin/Sterling-MBP
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = inputs // {
              inherit username;
              hostname = "Sterling-MBP";
            };
            home-manager.users.${username} = import ./home;
          }
        ];
      };

      # Example NixOS configuration
      nixosConfigurations."your-nixos-host" = nixos.lib.nixosSystem {
        system = nixosSystem;
        specialArgs = inputs // {
          inherit username;
          hostname = "your-nixos-host";
        };
        modules = [
          ./hosts/nixos/your-nixos-host
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = inputs // {
              inherit username;
              hostname = "your-nixos-host";
            };
            home-manager.users.${username} = import ./home;
          }
        ];
      };
    };
}

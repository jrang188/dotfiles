{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
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
      darwin,
      wsl,
      nixpkgs,
      home-manager,
    }:
    let
      username = "sirwayne";

      darwin-m1 = {
        system = "aarch64-darwin"; # aarch64-darwin or x86_64-darwin
        hostname = "Sterling-MBP";
        specialArgs = inputs // {
          inherit username;
          hostname = darwin-m1.hostname;
        };
      };

      nixos-wsl = {
        system = "x86_64-linux";
        hostname = "NixOS-WSL";
        specialArgs = inputs // {
          inherit username;
          hostname = nixos-wsl.hostname;
        };
      };
    in
    {
      darwinConfigurations."${darwin-m1.hostname}" = darwin.lib.darwinSystem {
        specialArgs = darwin-m1.specialArgs;
        system = darwin-m1.system;
        modules = [
          ./modules/nix-core.nix
          ./modules/darwin/host-users.nix
          ./modules/darwin/apps.nix
          ./modules/darwin/system.nix

          # home manager
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = darwin-m1.specialArgs;
            home-manager.users.${username} = import ./home;
          }
        ];
      };

      nixosConfigurations."${nixos-wsl.hostname}" = nixpkgs.lib.nixosSystem {
        specialArgs = nixos-wsl.specialArgs;
        system = nixos-wsl.system;
        modules = [
          ./modules/nix-core.nix
          ./modules/wsl/host-users.nix
          ./modules/wsl/apps.nix
          ./modules/wsl/system.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = nixos-wsl.specialArgs;
            home-manager.users.${username} = import ./home;
          }
          {
            system.stateVersion = "24.05";
            wsl.enable = true;
          }
        ];
      };

      # nix code formatter
      formatter.${darwin-m1.system} = nixpkgs.${darwin-m1.system}.nixfmt-rfc-style;
    };
}

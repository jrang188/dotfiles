{ lib, ... }:

let
  # Common configuration for unstable packages
  mkUnstablePkgs =
    { system, nixpkgs-unstable }:
    import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

  # Common specialArgs for all configurations
  mkSpecialArgs =
    {
      inputs,
      username,
      hostname,
      system,
      nixpkgs-unstable,
      extraArgs ? { },
    }:
    inputs
    // {
      inherit username hostname;
      pkgs-unstable = mkUnstablePkgs { inherit system nixpkgs-unstable; };
    }
    // extraArgs;

  # Common home-manager configuration
  mkHomeManagerConfig =
    {
      inputs,
      username,
      hostname,
      system,
      nixpkgs-unstable,
      homeImports,
      extraArgs ? { },
    }:
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = mkSpecialArgs {
        inherit
          inputs
          username
          hostname
          system
          nixpkgs-unstable
          extraArgs
          ;
      };
      home-manager.users.${username} = {
        imports = homeImports;
      };
    };

in
{
  inherit mkSpecialArgs mkHomeManagerConfig;
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl-micro = {
      url = "github:Avunu/nixos-wsl-micro";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl-micro,
    }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { nix.nixPath = [ "nixpkgs=${self.inputs.nixpkgs}" ]; }
            nixos-wsl-micro.nixosModules.wsl
            {
              wslMicro = {
                defaultUser = "nixos";
                stateVersion = "25.11";
                dockerIntegration = true;
                extraPackages = [ ];
              };
            }
          ];
        };
      };
    };
}

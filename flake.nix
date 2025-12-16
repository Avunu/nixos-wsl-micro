{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      vscode-server,
      ...
    }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [

            nixos-wsl.nixosModules.default

            vscode-server.nixosModules.default

            (
              { pkgs, lib, ... }:
              {

                environment.systemPackages = with pkgs; [
                  curl
                  git
                  nano
                  nix-output-monitor
                  nixfmt-rfc-style
                  nixos-container
                  tzdata
                  wget
                ];

                nix.settings = {
                  experimental-features = [
                    "nix-command"
                    "flakes"
                  ];
                };

                programs = {
                  direnv = {
                    enable = true;
                    nix-direnv.enable = true;
                  };
                  nix-ld.enable = true;
                };

                services.vscode-server.enable = true;

                system = {
                  stateVersion = "24.11";
                };

                users = {
                  users.nixos = {
                    isNormalUser = true;
                    extraGroups = [
                      "docker"
                      "wheel"
                    ];
                    shell = pkgs.bashInteractive;
                  };
                };

                wsl = {
                  enable = true;
                  defaultUser = "nixos";
                  docker-desktop.enable = true;
                  startMenuLaunchers = true;
                  useWindowsDriver = true;
                };
              }
            )
          ];
        };
      };
    };
}

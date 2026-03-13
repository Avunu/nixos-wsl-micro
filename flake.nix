{
  description = "NixOS WSL Micro Configuration";

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
    inputs@{
      self,
      nixpkgs,
      nixos-wsl,
      vscode-server,
      ...
    }:
    let
      lib = nixpkgs.lib;
    in
    {
      nixosModules.wsl =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        with lib;
        let
          cfg = config.wslMicro;
        in
        {
          imports = [
            inputs.nixos-wsl.nixosModules.default
            inputs.vscode-server.nixosModules.default
          ];

          options.wslMicro = {
            defaultUser = mkOption {
              type = types.str;
              default = "nixos";
              description = "Default WSL user";
            };
            stateVersion = mkOption {
              type = types.str;
              default = "24.11";
              description = "NixOS state version";
            };
            extraPackages = mkOption {
              type = types.listOf types.package;
              default = [ ];
              description = "Additional packages to install";
            };
            dockerIntegration = mkOption {
              type = types.bool;
              default = true;
              description = "Enable Docker Desktop integration";
            };
            autoUpgrade = mkOption {
              type = types.bool;
              default = true;
              description = "Enable automatic daily NixOS upgrades";
            };
          };

          config = {
            environment.systemPackages =
              with pkgs;
              [
                curl
                git
                nano
                nix-output-monitor
                nixfmt
                nixos-container
                tzdata
                wget
              ]
              ++ cfg.extraPackages;

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
              stateVersion = cfg.stateVersion;
              autoUpgrade = lib.mkIf cfg.autoUpgrade {
                enable = true;
                allowReboot = false;
                dates = "daily";
                flake = "/etc/nixos/flake.nix";
                flags = [
                  "--update-input"
                  "nixos-wsl-micro"
                  "--update-input"
                  "nixpkgs"
                  "--refresh"
                  "--impure"
                ];
              };
            };

            users.users.${cfg.defaultUser} = {
              isNormalUser = true;
              extraGroups =
                [ "wheel" ]
                ++ lib.optional cfg.dockerIntegration "docker";
              shell = pkgs.bashInteractive;
            };

            wsl = {
              enable = true;
              defaultUser = cfg.defaultUser;
              docker-desktop.enable = cfg.dockerIntegration;
              startMenuLaunchers = true;
              useWindowsDriver = true;
            };
          };
        };
    };
}

# nixos-wsl-micro

A minimal, flake-based NixOS-WSL configuration for local development. Exposes a reusable `nixosModules.wsl` module consumed by a locally-deployed `local/flake.nix` that you own and customize.

## Features

- **Flakes + nix-command** — enabled out of the box
- **nix-direnv** — automatic per-project dev shells via `.envrc`
- **nix-ld** — run unpatched Linux binaries (e.g. pre-built VSCode extensions, language servers)
- **VS Code Server** — seamless `code .` support from Windows via the [nixos-vscode-server](https://github.com/nix-community/nixos-vscode-server) service
- **Docker Desktop integration** — mounts the Windows Docker Desktop socket into WSL (optional, on by default)
- **Auto-upgrade** — daily `nixos-rebuild` against the upstream flake, no reboots (optional, on by default)
- **Base packages** — `curl`, `git`, `nano`, `wget`, `nixfmt`, `nix-output-monitor`, `tzdata`

## Quick Start

### 1. Install NixOS-WSL

Follow the [NixOS-WSL installation guide](https://nix-community.github.io/NixOS-WSL/install.html) to get a base NixOS distro running under WSL2.

### 2. Apply the default configuration

From within the NixOS WSL shell, run:

```sh
nixos-rebuild switch --flake github:Avunu/nixos-wsl-micro#nixos --refresh
```

This applies the module with all defaults. If the command fails (common on a fresh install before the WSL integration is fully initialized), run the recovery command from PowerShell first:

```powershell
wsl -d NixOS --system --user root -- /mnt/wslg/distro/bin/nixos-wsl-recovery
```

Then retry `nixos-rebuild`.

### 3. Deploy a local flake for customization

To configure the system with your own settings, copy the local flake to `/etc/nixos`:

```sh
sudo cp -r $(nix flake prefetch github:Avunu/nixos-wsl-micro --json | jq -r .storePath)/local/. /etc/nixos/
```

Or manually create `/etc/nixos/flake.nix` based on the template in [local/flake.nix](local/flake.nix).

Then switch to it:

```sh
nixos-rebuild switch --flake /etc/nixos#nixos
```

## Configuring the local flake

Edit `/etc/nixos/flake.nix` and set options under `wslMicro`:

```nix
wslMicro = {
  defaultUser = "nixos";       # WSL default user
  stateVersion = "25.11";      # NixOS state version — set once, do not change
  dockerIntegration = true;    # Mount Windows Docker Desktop socket
  autoUpgrade = true;          # Daily automatic nixos-rebuild
  extraPackages = with pkgs; [ # Any extra packages you want system-wide
    ripgrep
    fd
  ];
};
```

After editing, apply with:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

### Options reference

| Option | Type | Default | Description |
|---|---|---|---|
| `defaultUser` | string | `"nixos"` | Primary WSL user |
| `stateVersion` | string | `"24.11"` | NixOS state version |
| `dockerIntegration` | bool | `true` | Enable Docker Desktop socket integration |
| `autoUpgrade` | bool | `true` | Enable daily automatic upgrades |
| `extraPackages` | list | `[]` | Additional system packages |

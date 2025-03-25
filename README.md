Minimum flake-enabled NixOS-WSL config, preconfigured for local development, including VSCode and Windows Docker Desktop integration.

To use, [install](https://nix-community.github.io/NixOS-WSL/install.html) [NixOS-WSL](https://github.com/nix-community/NixOS-WSL), then apply with:

```Shell
nixos-rebuild switch --flake github:Avunu/nixos-wsl-micro#nixos --refresh
```

If the above command fails, try:

```PowerShell
wsl -d NixOS --system --user root -- /mnt/wslg/distro/bin/nixos-wsl-recovery
```

Then rerun `nixos-rebuild`, as above.

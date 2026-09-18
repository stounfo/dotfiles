# Dotfiles

NixOS and macOS configuration with Home Manager. See [arch.md](arch.md) for architecture.

Run commands from the repository root. Configured for user `stounfo` and Apple Silicon.

## NixOS

```bash
sudo nixos-rebuild switch --flake path:.#nixos --impure
```

## macOS

Install [Nix](https://github.com/nix-darwin/nix-darwin#prerequisites) and open a new terminal.
For Determinate Nix, set `nix.enable = false;` in `hosts/macbook/default.nix`.

First run:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-darwin/nix-darwin/master#darwin-rebuild -- switch --flake path:.#macbook
```

Apply changes:

```bash
sudo darwin-rebuild switch --flake path:.#macbook
```

## Update dependencies

```bash
nix flake update
```

Then apply the configuration for your OS.

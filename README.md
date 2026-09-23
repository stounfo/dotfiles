# Dotfiles

## NixOS

### Bootstrap

Clone the repository:

```bash
git clone <repo-url> ~/Projects/dotfiles
cd ~/Projects/dotfiles
```

On Apple Silicon, import the Asahi firmware into the Nix store:

```bash
nix-store --add-fixed sha256 /boot/vendorfw/firmware.cpio
```

Apply the configuration:

```bash
sudo nixos-rebuild switch --flake path:.#nixos-1
```

### Apply changes

```bash
sudo nixos-rebuild switch --flake path:.#nixos-1
```

### Check configuration

```bash
nix flake check path:.
```

## macOS

### Bootstrap / apply changes

```bash
darwin-rebuild switch --flake path:.#darwin-1
```

### Check configuration

```bash
nix flake check path:.
```

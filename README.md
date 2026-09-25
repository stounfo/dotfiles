# Dotfiles

Nix driven dotfiles for NixOS and macOS. Always a WIP.

## Requirements

- [Nix](https://nixos.org/download/)
- [Git](https://git-scm.com/downloads)
- [Make](https://www.gnu.org/software/make/)

Development dependencies are provided by the Nix development shell.

## Installation

Clone the repository with its Git submodules.

If the repository was cloned without submodules, initialize them with:

```bash
git submodule update --init --recursive
```

Configure the corresponding host in `hosts/<host>/descriptor.nix`.

At minimum, check:

```nix
user = {
  name = "...";
  home = "...";
};

repoRoot = "...";
```

`repoRoot` must point to the local path of this repository.

### NixOS

On Apple Silicon, import the Asahi firmware into the Nix store:

```bash
nix-store --add-fixed sha256 /boot/vendorfw/firmware.cpio
```

Apply the configuration:

```bash
make switch TARGET=nixos-1
```

### macOS

Apply the configuration:

```bash
make switch TARGET=darwin-1
```

## Development

Enter the development shell:

```bash
make shell-enter
```

Run all checks:

```bash
make check
```

Build a host without activating it:

```bash
make build TARGET=nixos-1
make build TARGET=darwin-1
```

Show all available commands:

```bash
make help
```

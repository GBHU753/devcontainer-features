
# Nix Package Manager via Determinate Systems Installer (nix)

Installs the Nix package manager and optionally a flake

## Example Usage

```json
"features": {
    "ghcr.io/GBHU753/devcontainer-features/nix:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | You can pin to a specific version of Determinate Nix Installer. if you pin the installer version, you'll also indirectly pin to the associated nix version. | string | - |
| flakeUri | Optional URI to a Nix Flake to install in using 'home-manager switch' after Nix is installed. | string | - |
| extraConfig | Extra Nix configuration to be written directly to nix.conf file. | string | - |

# Requirements

This feature requires that `curl` is installed in the image.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/GBHU753/devcontainer-features/blob/main/src/nix/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._

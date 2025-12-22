#!/bin/sh
set -e

echo "Activating feature 'Nix package manager via Determinate Systems Installer'"

# Build extra-conf with sandbox = false and any additional config
EXTRA_CONF="sandbox = false"
if [ -n "$EXTRACONFIG" ]; then
    EXTRA_CONF="$EXTRA_CONF
$EXTRACONFIG"
fi

# Install Nix via Determinate Systems installer
if [ -n "$VERSION" ]; then
    echo "Using Determinate Systems Nix version: $VERSION"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix/tag/$VERSION | \
    sh -s -- install linux \
      --extra-conf "$EXTRA_CONF" \
      --init none \
      --no-confirm
else 
    echo "Using latest Determinate Systems Nix version"
    curl -fsSL https://install.determinate.systems/nix | \
    sh -s -- install linux \
      --extra-conf "$EXTRA_CONF" \
      --init none \
      --no-confirm
fi

# Source nix environment
. "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

# Install flake using home-manager switch if specified
if [ -n "$FLAKEURI" ]; then
    echo "Installing Home Manager configuration from URI: $FLAKEURI"

    # Set USER from HOME if not already set
    USER="${USER:-$(basename "$HOME")}"
    export USER
    echo "Using USER: $USER"

    if nix run home-manager/master -- switch --flake "$FLAKEURI" --no-write-lock-file -b backup; then
        echo "Home Manager switch completed successfully"
    else
        echo "ERROR: Home Manager switch failed with exit code: $?"
        exit 1
    fi
fi
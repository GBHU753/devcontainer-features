#!/bin/sh
set -e

echo "Activating feature 'Nix package manager via Determinate Systems Installer'"

# Build install args from environment variables
INSTALL_ARGS="--no-confirm --init none"

if [ -n "$EXTRACONFIG" ]; then
    INSTALL_ARGS="$INSTALL_ARGS --extra-conf $EXTRACONFIG"
fi

# Install Nix via Determinate Systems installer
if [ -n "$VERSION" ]; then
    echo "Using Determinate Systems Nix version: $VERSION"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix/tag/$VERSION | \
    sh -s -- install linux $INSTALL_ARGS
else 
    echo "Using latest Determinate Systems Nix version"
    curl -fsSL https://install.determinate.systems/nix | \
    sh -s -- install linux $INSTALL_ARGS
fi

# Install nix flake if specified
if [ -n "$FLAKEURI" ]; then
    echo "Installing Nix flake from URI: $FLAKEURI"
    . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    nix profile add --no-write-lock-file "$FLAKEURI" 
fi  

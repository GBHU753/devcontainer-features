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

# Source nix environment
. "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

# Install flake using home-manager switch if specified
if [ -n "$FLAKEURI" ]; then
    echo "Installing Home Manager configuration from URI: $FLAKEURI"

    # Set USER from HOME if not already set
    USER="${USER:-$(basename "$HOME")}"
    export USER
    echo "Using USER: $USER"
    
    # Install home manager using nix shell
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update

    nix-shell '<home-manager>' -A install
    
    # Run home-manager switch with the flake URI
    # FLAKEURI should be in format: github:user/repo#configName or path#configName
    home-manager switch --flake "$FLAKEURI" --no-write-lock-file -b backup
fi
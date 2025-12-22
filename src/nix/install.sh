#!/bin/sh
set -e

echo "Setting up Nix Feature..."

# 1. Create the Runtime Entrypoint Script
cat > /usr/local/bin/nix-entrypoint.sh << 'EOF'
#!/bin/sh
set -e

# --- A. Check and Install Nix (Runtime) ---
# If the nix executable is not found in the expected location, we assume
# the volume is empty (or new) and we need to install Nix.
if [ ! -e "/nix/var/nix/profiles/default/bin/nix" ]; then
    echo "Nix not found in /nix volume. Installing..."
    
    # Using Determinate Systems installer with --init none
    # This installs into the mounted volume
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux \
      --init none \
      --no-confirm
else
    echo "Nix is already installed."
fi

# --- B. Source Nix Environment ---
if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
    . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

# --- C. Configure Nix ---
# Ensure the config exists (idempotent)
mkdir -p /etc/nix
if ! grep -q "experimental-features = nix-command flakes" /etc/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
fi
# Add extra config if environment variable is present
if [ -n "$NIX_EXTRA_CONF" ]; then
    echo "$NIX_EXTRA_CONF" >> /etc/nix/nix.conf
fi

# --- D. Handle Flake Installation ---
EOF

# Inject the FLAKEURI and EXTRACONFIG variables from build time
echo "TARGET_FLAKE_URI=\"$FLAKEURI\"" >> /usr/local/bin/nix-entrypoint.sh
echo "Nix_EXTRA_CONF=\"$EXTRACONFIG\"" >> /usr/local/bin/nix-entrypoint.sh

# Finish the script
cat >> /usr/local/bin/nix-entrypoint.sh << 'EOF'

if [ -n "$TARGET_FLAKE_URI" ]; then
    echo "Ensuring Home Manager configuration is applied..."
    
    # Determine user
    CURRENT_USER=$(whoami)
    if [ "$CURRENT_USER" = "root" ] && [ -n "$_REMOTE_USER" ]; then
        CURRENT_USER="$_REMOTE_USER"
    fi
    export USER="$CURRENT_USER"

    # We need to run home-manager. If we are root, we might want to drop privileges
    # or just run it. Usually in devcontainers, running as the user is safer.
    
    # Note: --no-write-lock-file is important for flakes in CI/CD like envs
    # Note: Using || true to prevent container crash if internet is flaky
    nix run home-manager/master -- switch --flake "$TARGET_FLAKE_URI" --no-write-lock-file -b backup || echo "Warning: Home Manager switch failed."
fi

# Pass control to the next command (CMD)
exec "$@"
EOF

# Make it executable
chmod +x /usr/local/bin/nix-entrypoint.sh

echo "Nix setup complete. Installation will occur at container start."
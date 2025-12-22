#!/bin/sh
set -e

echo "Activating feature 'Nix package manager'"

# --- 1. Install Nix (Same as before) ---
EXTRA_CONF="sandbox = false"
if [ -n "$EXTRACONFIG" ]; then
    EXTRA_CONF="$EXTRA_CONF
$EXTRACONFIG"
fi

# Determine Version and Install
if [ -n "$VERSION" ]; then
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix/tag/$VERSION | \
    sh -s -- install linux --extra-conf "$EXTRA_CONF" --init none --no-confirm
else 
    curl -fsSL https://install.determinate.systems/nix | \
    sh -s -- install linux --extra-conf "$EXTRA_CONF" --init none --no-confirm
fi

# --- 2. Create the Runtime Entrypoint Script ---
# We write the script to /usr/local/bin so it can be called by the feature entrypoint
cat > /usr/local/bin/nix-entrypoint.sh << 'EOF'
#!/bin/sh
set -e

# Source Nix
if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
  . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

# Define the Flake URI captured from build args
EOF

# Append the FLAKEURI variable into the script safely
echo "TARGET_FLAKE_URI=\"$FLAKEURI\"" >> /usr/local/bin/nix-entrypoint.sh

# Append the rest of the logic
cat >> /usr/local/bin/nix-entrypoint.sh << 'EOF'

if [ -n "$TARGET_FLAKE_URI" ]; then
    # Only run if we haven't successfully switched to this specific commit/flake before
    # Or just run it every time (idempotent):
    echo "Ensuring Home Manager configuration is applied..."
    
    # We need to set USER for home-manager
    export USER="${USER:-$(basename "$HOME")}"
    
    # Run Home Manager
    # We use '|| true' so container start doesn't fail if internet is down, 
    # but strictly speaking you might want it to fail.
    nix run home-manager/master -- switch --flake "$TARGET_FLAKE_URI" --no-write-lock-file -b backup || echo "Home Manager switch failed, continuing anyway..."
fi

# Execute the command passed to the container (usually /bin/sh or sleep infinity)
exec "$@"
EOF

# Make it executable
chmod +x /usr/local/bin/nix-entrypoint.sh

echo "Nix feature installed. Home Manager will apply at container start."
#!/bin/bash

# This test file will be executed against the 'flake' scenario
# which installs Nix with a specific flake

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Debug: output the result of the command
echo "DEBUG: Testing 'zsh -c \"command -v nix\"'"
zsh -c "command -v nix" || echo "DEBUG: Command failed or nix not found"

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "nix is installed" bash -c "command -v nix"

check "nix version" bash -c "nix --version"

check "nix.conf exists" bash -c "test -f /etc/nix/nix.conf"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults

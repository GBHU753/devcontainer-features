#!/bin/bash

# This test file will be executed against the 'nix' scenario
# which installs Nix without a specific flake

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "nix is installed" zsh -c "command -v nix"

check "nix version" zsh -c "nix --version"

check "nix.conf exists" zsh -c "test -f /etc/nix/nix.conf"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults

#!/bin/bash

# This test file will be executed against the 'flake' scenario
# which installs Nix with a specific flake

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "fastfetch is installed" bash -c "command -v fastfetch"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults

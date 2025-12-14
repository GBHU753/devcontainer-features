#!/bin/bash

set -e

echo "Testing Nix installation..."

# Check if nix is installed
if command -v nix &> /dev/null; then
    echo "✓ Nix is installed"
    nix --version
else
    echo "✗ Nix is not installed"
    exit 1
fi

# Check if nix.conf exists
if [ -f /etc/nix/nix.conf ]; then
    echo "✓ nix.conf exists"
else
    echo "✗ nix.conf not found"
    exit 1
fi

echo "All tests passed!"

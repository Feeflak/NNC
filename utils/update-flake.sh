#!/usr/bin/env bash
set -euo pipefail

cd /etc/nixos/NNC

nix-shell -p secretspec --run 'secretspec run --file ./secretspec.toml --profile development -- bash -c "
  sudo -E nix flake update --access-tokens github.com=$GITHUB_TOKEN
"'

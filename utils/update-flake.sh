#!/usr/bin/env bash
set -euo pipefail

cd /etc/nixos/NNC

nix-shell -p secretspec --run 'secretspec run --file /etc/nixos/NNC/secretspec.toml -- bash -c "
  sudo -E -H nix flake update --access-tokens github.com=$GITHUB_TOKEN
"'

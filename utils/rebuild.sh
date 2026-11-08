#!/usr/bin/env bash
set -euo pipefail

cd /etc/nixos/NNC

host="$(cat /etc/nixos/host.txt)"

git add '*'

nix-shell -p secretspec --run 'secretspec run --file /etc/nixos/NNC/secretspec.toml  -- bash -c "
  sudo -E nix run .#write-flake --access-tokens github.com=$GITHUB_TOKEN
  sudo -E nixos-rebuild switch --upgrade --impure --flake .#'"$host"'
"'

#!/usr/bin/env bash
set -euo pipefail

cd /etc/nixos/NNC

host="$(cat /etc/nixos/host.txt)"

git add '*'

secretspec run --file /etc/nixos/NNC/secretspec.toml --reason "Rebuild NixOS system" -- bash -c '
  sudo -E -H nix run --access-tokens github.com=$GITHUB_TOKEN .#write-flake
  sudo -E -H nixos-rebuild switch --upgrade --impure --flake .#'"$host"' --option access-tokens "github.com=$GITHUB_TOKEN"
'

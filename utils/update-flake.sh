#!/usr/bin/env bash
set -euo pipefail

cd /etc/nixos/NNC


secretspec run --file /etc/nixos/NNC/secretspec.toml --reason "Rebuild NixOS system" -- bash -c '
  sudo -E -H nix flake update --access-tokens github.com=$GITHUB_TOKEN
'

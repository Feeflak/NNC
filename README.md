# NNC

NewNixConfig

## Running My Nvf Config on Other Machines

`nix run --refresh github:FilipRuman/NNC?dir=nvf/selfcontained`

## Installation

Installation command, I'm not responsible form any harm done by this command.
You need to set the INSTALL_USER to: `pc/laptop/server` depending on what user
script you want to install\
`*_*`

1. set what host you want to use

```bash
bash ; export host=<desktop/laptop/server>
```

2. install eaverything:



```bash
sudo rm -rf /etc/nixos # risky one but OH WELL, this is a clean machine anyway! :D
mkdir /etc/nixos/
cd /etc/nixos || exit
sudo echo "$host" >./host.txt
# On update file
touch onUpdate.sh
sudo chmod +x onUpdate.sh
sudo git clone https://github.com/Feeflak/NNC.git
cd ./NNC/ || exit
sudo nixos-rebuild switch --upgrade --flake ".#$host"
```

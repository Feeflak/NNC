{
  flake.nixosModules.networking = { lib, ... }: {
    networking.hostName = "nixos"; # define your hostname.
    networking.networkmanager.enable = true;
    services.tailscale.enable = true;
    systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];
    networking.firewall = {
      enable = true;

      interfaces.wlp13s0 = {
        allowedUDPPorts = [
          67
          53
        ];
        allowedTCPPorts = [ 53 ];
      };
    };
  };
}

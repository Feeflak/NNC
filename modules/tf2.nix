
{
  flake.nixosModules.tf2=
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # flightcore removed: not available in nixos-26.05 stable
      ];
    };
}


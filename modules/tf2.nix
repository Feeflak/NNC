
{
  flake.nixosModules.tf2=
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
flightcore
      ];
    };
}


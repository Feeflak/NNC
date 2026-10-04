{
  flake.nixosModules.cad = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      kicad
    ];
  };
}

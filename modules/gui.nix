{
  flake.nixosModules.gui =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        gimp3
        # signal-desktop
        gparted
        # firefox
        freecad
        ghostty
        orca-slicer
        opencode
        # kdePackages.dolphin
      ];
    };
}

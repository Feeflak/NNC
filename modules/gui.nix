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
        opencode
        # kdePackages.dolphin
      ];
    };
}

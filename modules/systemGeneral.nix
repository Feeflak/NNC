{

  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  flake.nixosModules.systemGeneral =
    { pkgs, ... }:
    {
      # Idk where else to put it

      nixpkgs.config.allowUnfree = true;

      time.timeZone = "Europe/Warsaw";
      boot.kernelPackages = pkgs.linuxPackages; # zen 7.2.7 is incompatible with nvidia-open in 26.05
      security.sudo.wheelNeedsPassword = false;
      services.gnome.gnome-keyring.enable = true;
      environment.systemPackages = with pkgs; [
        dbus
      ];
      services.dbus.enable = true;
      xdg.portal = {
        enable = true;

        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      imports = [
      ];
      system.stateVersion = "25.11";
    };
}

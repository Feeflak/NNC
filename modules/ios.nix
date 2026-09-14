{

  flake.nixosModules.ios = { pkgs, ... }: {

    nixpkgs.overlays = [
      (final: prev: {
        usbmuxd = prev.usbmuxd.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ../patches/usbmuxd-preflight-retry.patch ];
        });
      })
    ];

    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd;
    };
    environment.systemPackages = with pkgs; [
      libimobiledevice
      ifuse # optional, to mount using 'ifuse'
    ];
  };
}

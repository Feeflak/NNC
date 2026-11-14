{
  flake.nixosModules.plymouth = { pkgs, ... }: {
    boot = {
      plymouth = {
        enable = true;
        theme = "rings_2";
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override {
            selected_themes = [ "rings_2" ];
          })
        ];
      };

      # Enable "Silent boot"
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=auto"
      ];

      # Hide the OS choice for bootloaders.
      # Spam space when booting to show it anyway
      loader.timeout = 0;
    };
    boot.initrd.systemd.enable = true;
  };
}

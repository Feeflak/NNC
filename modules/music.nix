{
  flake.nixosModules.music = { pkgs, ... }: {

    services.mpd = {
      enable = true;
      musicDirectory = "/data/media/music";

      # network.startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
      settings = {
        audio_output = [
          {
            type = "alsa";
            name = "My ALSA";
            device = "hw:0,0"; # optional
            format = "44100:16:2"; # optional
            mixer_type = "hardware";
            mixer_device = "default";
            mixer_control = "PCM";
          }
        ];
      };
    };
    environment.systemPackages = with pkgs; [
      rmpc
    ];
  };
}

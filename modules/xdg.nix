{
  flake.homeModules.general =
    { config, pkgs, ... }:

    let
      yaziGhostty = pkgs.writeShellScriptBin "yazi-ghostty" ''
        set -eu

        DIR="''${1:-.}"

        exec ${pkgs.ghostty}/bin/ghostty -e ${pkgs.fish}/bin/fish -ic "cd \"$DIR\"; and yazi; and exec fish"
      '';
    in
    {
      home.packages = [
        yaziGhostty
      ];

      xdg.mimeApps.enable = true;
      xdg.dataFile."kio/servicemenus/yazi-directory.desktop".text = ''
        [Desktop Entry]
        Type=Service
        MimeType=inode/directory;
        Actions=open;

        [Desktop Action open]
        Name=Open in Yazi
        Exec=yazi-ghostty %f
      '';
      xdg.configFile."kdeglobals".text = ''
        [General]
        FileManager=yazi-ghostty.desktop
      '';
      xdg.mimeApps.defaultApplications = {
        "inode/directory" = [ "yazi-ghostty.desktop" ];

        "x-scheme-handler/http" = [ "zen.desktop" ];
        "x-scheme-handler/https" = [ "zen.desktop" ];
        "text/html" = [ "zen.desktop" ];
        "application/xhtml+xml" = [ "zen.desktop" ];

        "text/plain" = [ "neovide.desktop" ];

        "video/mp4" = [ "ffplay.desktop" ];
        "video/x-matroska" = [ "ffplay.desktop" ];
        "video/quicktime" = [ "ffplay.desktop" ];
        "video/webm" = [ "ffplay.desktop" ];
        "video/x-flv" = [ "ffplay.desktop" ];
        "video/x-msvideo" = [ "ffplay.desktop" ];
        "video/mpeg" = [ "ffplay.desktop" ];
        "video/ogg" = [ "ffplay.desktop" ];
        "video/x-m4v" = [ "ffplay.desktop" ];
        "video/x-matroska-3d" = [ "ffplay.desktop" ];
      };

      xdg.desktopEntries.yazi-ghostty = {
        name = "Yazi (Ghostty)";
        exec = "${yaziGhostty}/bin/yazi-ghostty %f";
        terminal = false;
        type = "Application";
        categories = [ "Utility" ];
        mimeType = [ "inode/directory" ];
      };

      xdg.desktopEntries.ffplay = {
        name = "FFplay";
        exec = "${pkgs.ffmpeg}/bin/ffplay %f";
        terminal = false;
        type = "Application";
        categories = [ "AudioVideo" "Video" "Player" ];
        mimeType = [
          "video/mp4"
          "video/x-matroska"
          "video/quicktime"
          "video/webm"
          "video/x-flv"
          "video/x-msvideo"
          "video/mpeg"
          "video/ogg"
          "video/x-m4v"
          "video/x-matroska-3d"
        ];
      };

      xdg.terminal-exec.enable = true;

      xdg.terminal-exec.settings = {
        default = [ "com.mitchellh.ghostty.desktop" ];
        Hyprland = [ "com.mitchellh.ghostty.desktop" ];
      };

      home.sessionVariables = {
        TERMINAL = "ghostty";
        BROWSER = "zen";
        EDITOR = "nvim";
        VISUAL = "neovide";
      };
    };
}

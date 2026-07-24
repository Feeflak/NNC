{
  flake.nixosModules.recording =
    { pkgs, ... }:
    {
      programs.gpu-screen-recorder.enable = true;
      environment.systemPackages = [
        pkgs.gpu-screen-recorder
        # pkgs.manim
        pkgs.losslesscut
        pkgs.wf-recorder
        pkgs.kdePackages.dolphin
        pkgs.grimblast
        pkgs.grim
        pkgs.slurp
        pkgs.zenity
        pkgs.audacity
        (pkgs.writeShellScriptBin "recording_tool" ''
          exec /etc/nixos/NNC/utils/recording_tool/target/debug/recording_tool "$@"
        '')

      ];

    };
}

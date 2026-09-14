{
  flake.nixosModules.terminalEnhancements =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        imagemagick
        wget
        fastfetch
        fzf
        fd
        starship
        zoxide
        ffmpeg
        # f3d
        yazi
        ripgrep
        fd
        fish
        delta # git diff
        libqalculate
        lazygit
        lf
        zip
        unrar
        unzip
      ];
    };
}

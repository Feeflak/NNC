{ inputs, ... }:
{
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.nixosModules.stylix =
    { pkgs, ... }:
    let
      fonts = import ./fonts/_consts.nix { inherit pkgs; };
    in
    {
      imports = [ inputs.stylix.nixosModules.stylix ];
      stylix = {
        enable = true;
        # base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
        # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night.yaml";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyodark-terminal.yaml";

        cursor = {
          size = 16;
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
        };
        autoEnable = true;
        targets = {
          grub.enable = false;
          plymouth.enable = false;
        };
        fonts = {
          sizes = {
            applications = 12;
            terminal = 15;
            desktop = 10;
            popups = 10;
          };
          monospace = {
            package = fonts.codePkg;
            name = fonts.codeName;
          };
          sansSerif = {
            package = fonts.sansSerifPkg;
            name = fonts.sansSerifName;
          };

          emoji = {
            package = fonts.emojiPkg;
            name = fonts.emojiName;
          };
        };
        opacity = {
          desktop = 0.5;
          terminal = 0.5;
        };
      };
    };

  flake.homeModules.general = {
    gtk.enable = true;
    qt.enable = true;

    stylix.targets = {
      noctalia-shell.enable = false;
      neovide.enable = false;
      dunst.enable = false;
      hyprlock.enable = false;
    };
  };
}

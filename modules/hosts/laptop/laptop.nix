{
  inputs,
  self,
  lib,
  ...
}:
{
  flake-file.inputs.home-manager = {
    url = lib.mkDefault "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];
  flake = {
    nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = with self.nixosModules; [
        auto_mount
        cs
        zig
        rust
        c
        js
        ocaml

        laptop
        hyprland
        audio
        bluetooth
        plymouth
        polkit
        sddm
        #plasma
        nvf
        gui
        #ctf
        # docker
        essentials
        flatpak
        zen
        steam
        fontsImport
        keyboardFlashing
        recording
        stylix
        terminalEnhancements
        # vm

        fUser
        nvidia
        networking
        systemGeneral
        systemdBoot
        #grub
      ];
    };

    nixosModules.laptop =
      { pkgs, ... }:
      {
        services.flatpak.packages = [
          "io.ente.auth"
          "com.brave.Browser"
          "com.discordapp.Discord"
        ];
        imports = [
          inputs.home-manager.nixosModules.default
        ];

        home-manager.users.f = {
          imports = with self.homeModules; [
            laptop
            general
          ];
          home = {
            stateVersion = "25.11";
            username = "f";
            homeDirectory = "/home/f";
          };
        };
        home-manager.backupFileExtension = "home-managebak";

        environment.systemPackages = with pkgs; [
          unityhub
          blender
        ];

        boot.initrd.kernelModules = [ "amdgpu" ];
        boot.kernelParams = [ "nvidia-drm.modeset=1" ];
      };
  };
}

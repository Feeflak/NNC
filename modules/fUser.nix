{
  flake.nixosModules.fUser = { pkgs, ... }: {
    programs.fish.enable = true;
    users.users.f = {
      isNormalUser = true;
      shell = pkgs.fish;
      description = "f";
      extraGroups = [
        "networkmanager"
        "wheel"
        "input"
        "uinput"
      ];
    };
  };
}

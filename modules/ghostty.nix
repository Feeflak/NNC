{
  flake.homeModules.general = { lib, ... }: {
    programs.ghostty.enable = true;
    programs.ghostty.settings = lib.mkForce {
      "background-opacity" = 1;
      "background-blur" = true;
      "clipboard-paste-protection" = false;
      "mouse-hide-while-typing" = true;
      "shell-integration" = "fish";
      "font-family" = "MesloLGM Nerd Font";
      "command" = "fish --login --interactive";
      "copy-on-select" = "clipboard";
    };
  };
}

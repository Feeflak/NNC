{inputs, ...}: {
  flake-file.inputs.nvf = {
    url = "github:NotAShelf/nvf";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.nixosModules.nvf = {pkgs, ...}: {
    programs.nvf = {
      enable = true;
      settings = ./_config/main.nix;
    };
    imports = [
      inputs.nvf.nixosModules.default
    ];
    environment.systemPackages = with pkgs; [
      neovide
    ];
  };
}

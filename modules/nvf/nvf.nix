{inputs, ...}: {
  flake-file.inputs.nvf = {
    url = "github:NotAShelf/nvf";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.nixosModules.nvf = {pkgs, ...}: {
    nixpkgs.overlays = [
      (final: prev: {
        fetchPnpmDeps = args:
          prev.fetchPnpmDeps (
            if (args.hash or args.sha256 or null) == "sha256-XgPnyFbA0ZjDh0uGUH1uOaMZas9QjQp8m7I2BgeBy3Q="
            then args // {hash = "sha256-TGJ+wEXdD9Pwy9G+FnLHAVzNBMW3epAM9+4qtQpAzA4=";}
            else args
          );
      })
    ];

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

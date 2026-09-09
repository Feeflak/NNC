{ inputs, ... }: {
  flake-file.inputs.zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
    inputs = {
      # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };
  };

  flake.nixosModules.zen = { pkgs, ... }: {

    environment.systemPackages = [
      inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];
  };
}

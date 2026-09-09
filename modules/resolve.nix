{ inputs, ... }: {
  flake-file.inputs.nixpkgs-resolve = {
    url = "github:NixOS/nixpkgs/e5bdc4a41d4c072fe1e3787eaa0320a384741d44";

    # url = "github:NixOS/nixpkgs/586b979a8ccb8f35d5fe06645dd678a8b343f16f";
  };

  flake.nixosModules.resolve = { pkgs, ... }: {
    environment.systemPackages = [
      (import inputs.nixpkgs-resolve {
        system = pkgs.system;
        config.allowUnfree = true;
      }).davinci-resolve
    ];
  };
}

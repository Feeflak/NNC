{ inputs, ... }: {
  flake-file.inputs.scal = {
    url = "github:feeflak/SCAL";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.nixosModules.scal = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.scal.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}

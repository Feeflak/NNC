{ ... }:
{
  flake.nixosModules.learnharness =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          learnharness = prev.callPackage ../pkgs/learnharness { };
        })
      ];

      environment.systemPackages = [ pkgs.learnharness ];
    };
}

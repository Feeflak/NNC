{
  flake.nixosModules.secrets =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.custom.secrets;
      isImpureEval = builtins.getEnv "PATH" != "";
      secretspec = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.secretspec;
    in
    {
      options.custom.secrets = {
        required = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Secret names that must be present in the environment at build time.";
        };

        values = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          readOnly = true;
          description = "Resolved secret values from environment variables.";
        };
      };

      config = {
        environment.systemPackages = [
          pkgs.sops
          secretspec
        ];

        custom.secrets.values = lib.listToAttrs (
          map (name: {
            inherit name;
            value = builtins.getEnv name;
          }) cfg.required
        );

        assertions = lib.optionals isImpureEval (
          map (name: {
            assertion = cfg.values.${name} != "";
            message = "secret ${name} is missing from the env variables. Use `secretspec run --file ./secretspec.toml --profile development -- sudo -E -H nixos-rebuild switch --impure --flake .#<host>` so SecretSpec injects it, and use `sudo -E` to preserve env variables";
          }) cfg.required
        );
      };
    };
}

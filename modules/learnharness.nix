{ lib, ... }:
let
  learnharness =
    {
      lib,
      appimageTools,
      fetchurl,
    }:
    let
      pname = "learnharness";
      version = "0.7.0";

      src = fetchurl {
        url = "https://github.com/amosblomqvist/learnharness/releases/download/v${version}/LearnHarness-${version}-x86_64.AppImage";
        hash = "sha256:772b5e04d380cbe8a72a75dbff269aeb6a47f4d4452711b1da8059a872067613";
      };

      appimageContents = appimageTools.extract { inherit pname version src; };
    in
    appimageTools.wrapType2 {
      inherit pname version src;

      extraInstallCommands = ''
        install -Dm444 ${appimageContents}/learnharness.desktop $out/share/applications/learnharness.desktop
        substituteInPlace $out/share/applications/learnharness.desktop \
          --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'

        install -Dm444 ${appimageContents}/usr/share/icons/hicolor/512x512/apps/learnharness.png \
          $out/share/icons/hicolor/512x512/apps/learnharness.png
      '';

      meta = {
        description = "Agent harness for learning difficult things";
        homepage = "https://github.com/amosblomqvist/learnharness";
        license = lib.licenses.agpl3Only;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        platforms = [ "x86_64-linux" ];
        mainProgram = "learnharness";
      };
    };
in
{
  perSystem = { pkgs, system, ... }: {
    packages = lib.optionalAttrs (system == "x86_64-linux") {
      learnharness = pkgs.callPackage learnharness { };
    };
  };

  flake.nixosModules.learnharness =
    { pkgs, inputs, ... }:
    {
      environment.systemPackages = [
        inputs.self.packages.${pkgs.system}.learnharness
      ];
    };
}

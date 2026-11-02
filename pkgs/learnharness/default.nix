{
  lib,
  appimageTools,
  fetchurl,
  makeDesktopItem,
}:
let
  pname = "learnharness";
  version = "0.4.1";

  src = fetchurl {
    url = "https://github.com/amosblomqvist/learnharness/releases/download/v${version}/LearnHarness-${version}-x86_64.AppImage";
    hash = "sha256-n8aA23BE2DD7yePDAbuWcLc29jo22bYivln2toh3DNg=";
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
}

{ lib, appimageTools, fetchurl }:

appimageTools.wrapType2 rec {
  pname = "learnharness";
  version = "0.4.0";

  src = fetchurl {
    url = "https://github.com/amosblomqvist/learnharness/releases/download/v${version}/LearnHarness-${version}-x86_64.AppImage";
    hash = "sha256-LbsR4gEGf2Qu9a7isSKJDxEeFC3k6dZMtx5X765oDgM=";
  };

  meta = {
    description = "Agent harness for learning difficult things";
    homepage = "https://github.com/amosblomqvist/learnharness";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "learnharness";
  };
}

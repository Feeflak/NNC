{ lib, appimageTools, fetchurl }:

appimageTools.wrapType2 rec {
  pname = "learnharness";
  version = "0.4.0";

  src = fetchurl {
    url = "https://github.com/amosblomqvist/learnharness/releases/download/v${version}/LearnHarness-${version}-x86_64.AppImage";
    hash = "sha256-00qfd2pfymqynx6ddsg45la1w48gi4ib3qmfylp68zq607i13frd";
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

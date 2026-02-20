{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

# Latest version: https://dl.wisprflow.com/wispr-flow/darwin/arm64/RELEASES.json
stdenvNoCC.mkDerivation {
  pname = "wispr-flow";
  version = "1.4.351";

  src = fetchurl {
    url = "https://dl.wisprflow.com/wispr-flow/darwin/arm64/dmgs/Flow-v1.4.351.dmg";
    hash = "sha256-y+fnowPBmL4yXZcFxnNd3faF6yXCvlJXMdfQRvovipM=";
  };

  nativeBuildInputs = [ _7zz ];
  sourceRoot = "Flow-v1.4.351/Wispr Flow.app";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications/Wispr Flow.app"
    cp -R . "$out/Applications/Wispr Flow.app"

    # 7zz extracts APFS extended attributes as separate files (e.g. "file:com.apple.provenance").
    # These break code signature verification, so remove them.
    find "$out" -name '*:com.apple.*' -delete
    runHook postInstall
  '';

  meta = {
    description = "Voice-to-text dictation with AI-powered auto-editing";
    homepage = "https://wisprflow.ai/";
    license = lib.licenses.unfree;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}

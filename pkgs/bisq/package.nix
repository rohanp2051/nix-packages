{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

stdenvNoCC.mkDerivation {
  pname = "bisq";
  version = "1.9.22";

  src = fetchurl {
    url = "https://github.com/bisq-network/bisq/releases/download/v1.9.22/Bisq-1.9.22.dmg";
    hash = "sha256-mpPo3wC9KTZfITwETgrxBoU6gvGzA/caKqPcbZBsFFA=";
  };

  nativeBuildInputs = [ _7zz ];
  sourceRoot = "Bisq/Bisq.app";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications/Bisq.app"
    cp -R . "$out/Applications/Bisq.app"

    # 7zz extracts APFS extended attributes as separate files (e.g. "file:com.apple.provenance").
    # These break code signature verification, so remove them.
    find "$out" -name '*:com.apple.*' -delete

    # Re-sign with ad-hoc signature so macOS Gatekeeper doesn't reject the app.
    /usr/bin/codesign --force --deep --sign - \
      "$out/Applications/Bisq.app"
    runHook postInstall
  '';

  meta = {
    description = "Decentralized bitcoin exchange network";
    homepage = "https://bisq.network/";
    license = lib.licenses.agpl3Only;
    # Bisq 1 is built for x86_64 macOS; requires Rosetta 2 on Apple Silicon.
    platforms = [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}

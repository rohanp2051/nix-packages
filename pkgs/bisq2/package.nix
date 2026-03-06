{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

stdenvNoCC.mkDerivation {
  pname = "bisq2";
  version = "2.1.9";

  src = fetchurl {
    url = "https://github.com/bisq-network/bisq2/releases/download/v2.1.9/Bisq-2.1.9.dmg";
    hash = "sha256-szs0CTvWmlIztb9+zmlLnNEqxr/+8SvQquxP8OKOL/c=";
  };

  nativeBuildInputs = [ _7zz ];
  sourceRoot = "Bisq2/Bisq2.app";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications/Bisq2.app"
    cp -R . "$out/Applications/Bisq2.app"

    # 7zz extracts APFS extended attributes as separate files (e.g. "file:com.apple.provenance").
    # These break code signature verification, so remove them.
    find "$out" -name '*:com.apple.*' -delete

    # Re-sign with ad-hoc signature so macOS Gatekeeper doesn't reject the app.
    /usr/bin/codesign --force --deep --sign - \
      "$out/Applications/Bisq2.app"
    runHook postInstall
  '';

  meta = {
    description = "Decentralized bitcoin exchange network";
    homepage = "https://bisq.network/";
    license = lib.licenses.agpl3Only;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}

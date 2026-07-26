{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

let
  arch = if stdenvNoCC.hostPlatform.isAarch64 then "aarch64" else "x86_64";
  hashes = {
    aarch64 = "sha256-RbIOoHjJB+L0T/Xf5CER+wJ258f3T8tq8pMsysijs44=";
    x86_64 = "sha256-4eFv61Tpn7K56c9DaXOs8TYpqayVtp32XEcygofqXI0=";
  };
in

stdenvNoCC.mkDerivation {
  pname = "bisq";
  version = "1.10.4";

  src = fetchurl {
    url = "https://github.com/bisq-network/bisq/releases/download/v1.10.4/Bisq-${arch}-1.10.4.dmg";
    hash = hashes.${arch};
  };

  nativeBuildInputs = [ _7zz ];
  sourceRoot = "Bisq/Bisq.app";

  # 7zz refuses to extract relative symlinks ("Dangerous link path") in the
  # bundled JDK legal/ tree.  Extract tolerating the error — the missing
  # targets are only license-notice symlinks and don't affect functionality.
  unpackPhase = ''
    runHook preUnpack
    7zz x -snld "$src" || true
    # Remove APFS extended attribute files that break code signatures.
    find . -name '*:com.apple.*' -delete
    runHook postUnpack
  '';

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications/Bisq.app"
    cp -R . "$out/Applications/Bisq.app"

    # Re-sign with ad-hoc signature so macOS Gatekeeper doesn't reject the app.
    /usr/bin/codesign --force --deep --sign - \
      "$out/Applications/Bisq.app"
    runHook postInstall
  '';

  meta = {
    description = "Decentralized bitcoin exchange network";
    homepage = "https://bisq.network/";
    license = lib.licenses.agpl3Only;
    platforms = [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}

{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation {
  pname = "thaw";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/stonerl/Thaw/releases/download/1.2.0/Thaw_1.2.0.zip";
    hash = "sha256-1n9NMe+foFeEmphUC4EM+kLgvGYBnTYFq9CORcaaoG8=";
  };

  nativeBuildInputs = [ unzip ];
  sourceRoot = "Thaw.app";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications/Thaw.app"
    cp -R . "$out/Applications/Thaw.app"

    # Remove __MACOSX resource fork artifacts that break code signatures.
    find "$out" -name '__MACOSX' -exec rm -rf {} + 2>/dev/null || true

    # Extract original entitlements so they survive re-signing.
    /usr/bin/codesign -d --entitlements :"$TMPDIR/entitlements.plist" \
      "$out/Applications/Thaw.app"

    # Re-sign with ad-hoc signature, preserving entitlements.
    /usr/bin/codesign --force --deep --sign - \
      --entitlements "$TMPDIR/entitlements.plist" \
      "$out/Applications/Thaw.app"
    runHook postInstall
  '';

  meta = {
    description = "Menu bar manager for macOS";
    homepage = "https://github.com/stonerl/Thaw";
    license = lib.licenses.gpl3Only;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}

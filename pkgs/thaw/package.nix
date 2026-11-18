{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

# Pinned to the 1.x line on purpose — do not bump past 1.2.0.
#
# Thaw 2.0 raised the minimum deployment target to macOS 26 Tahoe, and upstream
# states systems on macOS 14/15 stay on the 1.x line (thaw-app/Thaw#427). 1.2.0
# is therefore the last release that runs on Sequoia, which is also why the
# homebrew cask is unusable here (it declares `depends_on macos: :tahoe`).
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "thaw";
  version = "1.2.0";

  src = fetchurl {
    # Repo moved from stonerl/Thaw to thaw-app/Thaw; same artifact, same hash.
    url = "https://github.com/thaw-app/Thaw/releases/download/${finalAttrs.version}/Thaw_${finalAttrs.version}.zip";
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
    homepage = "https://github.com/thaw-app/Thaw";
    license = lib.licenses.gpl3Only;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})

{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
  asar,
}:

# Latest version: https://dl.wisprflow.com/wispr-flow/darwin/arm64/RELEASES.json
stdenvNoCC.mkDerivation {
  pname = "wispr-flow";
  version = "1.4.396";

  src = fetchurl {
    url = "https://dl.wisprflow.com/wispr-flow/darwin/arm64/dmgs/Flow-v1.4.396.dmg";
    hash = "sha256-paX9k9820rduaG5F+vc7eAtHAhlymhzSyM0/IbczVgs=";
  };

  nativeBuildInputs = [
    _7zz
    asar
  ];
  sourceRoot = "Flow-v1.4.396/Wispr Flow.app";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications/Wispr Flow.app"
    cp -R . "$out/Applications/Wispr Flow.app"

    # Patch out the "must be in /Applications" check so the app runs from the Nix store.
    # The Electron app verifies its path matches /Applications; bypass it for Nix.
    local asar_dir="$out/Applications/Wispr Flow.app/Contents/Resources"
    asar extract "$asar_dir/app.asar" "$TMPDIR/asar-contents"
    sed -i 's/"production"===\([a-zA-Z_$][a-zA-Z0-9_$.]*\)&&!r/"production"===\1\&\&!1/' \
      "$TMPDIR/asar-contents/.webpack/main/index.js"

    # Verify the patch applied (fail the build if the pattern wasn't found)
    if ! grep -q '"production"===.*&&!1' "$TMPDIR/asar-contents/.webpack/main/index.js"; then
      echo "ERROR: Failed to patch /Applications folder check — pattern may have changed" >&2
      exit 1
    fi
    asar pack "$TMPDIR/asar-contents" "$asar_dir/app.asar"

    # 7zz extracts APFS extended attributes as separate files (e.g. "file:com.apple.provenance").
    # These break code signature verification, so remove them.
    find "$out" -name '*:com.apple.*' -delete

    # Extract original entitlements so they survive re-signing (mic, camera, JIT, etc.).
    /usr/bin/codesign -d --entitlements :"$TMPDIR/entitlements.plist" \
      "$out/Applications/Wispr Flow.app"

    # Re-sign with ad-hoc signature, preserving entitlements.
    /usr/bin/codesign --force --deep --sign - \
      --entitlements "$TMPDIR/entitlements.plist" \
      "$out/Applications/Wispr Flow.app"
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

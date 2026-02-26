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
  version = "1.4.384";

  src = fetchurl {
    url = "https://dl.wisprflow.com/wispr-flow/darwin/arm64/dmgs/Flow-v1.4.384.dmg";
    hash = "sha256-Dj1cyfTULpQIu1zgCpTxdQOJhHnPS6dyq6oLgSfVyic=";
  };

  nativeBuildInputs = [
    _7zz
    asar
  ];
  sourceRoot = "Flow-v1.4.384/Wispr Flow.app";

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
    substituteInPlace "$TMPDIR/asar-contents/.webpack/main/index.js" \
      --replace-fail \
        '"production"===f.M0&&!r' \
        '"production"===f.M0&&!1'
    asar pack "$TMPDIR/asar-contents" "$asar_dir/app.asar"

    # 7zz extracts APFS extended attributes as separate files (e.g. "file:com.apple.provenance").
    # These break code signature verification, so remove them.
    find "$out" -name '*:com.apple.*' -delete

    # Re-sign with ad-hoc signature since patching the asar invalidates the original.
    /usr/bin/codesign --force --deep --sign - "$out/Applications/Wispr Flow.app"
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

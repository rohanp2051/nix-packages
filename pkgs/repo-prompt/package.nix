{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

stdenvNoCC.mkDerivation {
  pname = "repo-prompt";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/repoprompt/repoprompt-ce/releases/download/v1.1.0/RepoPrompt-1.1.0-31.dmg";
    hash = "sha256-dWGHO1PaAxVh8fOu4QLu8ElL/vWZgpGo1U1S3H8Ax5E=";
  };

  nativeBuildInputs = [ _7zz ];
  sourceRoot = "RepoPrompt CE.app";

  # 7zz refuses to extract relative symlinks ("Dangerous link path").
  # Extract with 7zz (tolerating the error), then recreate the symlinks.
  unpackPhase = ''
    runHook preUnpack
    7zz x -snld "$src" || true
    ln -sf ../MacOS/repoprompt-mcp "RepoPrompt CE.app/Contents/Resources/repoprompt-mcp"
    mkdir -p "RepoPrompt CE.app/Contents/Resources/bin"
    ln -sf ../../MacOS/repoprompt-mcp "RepoPrompt CE.app/Contents/Resources/bin/repoprompt-mcp"
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
    mkdir -p "$out/Applications/RepoPrompt CE.app"
    cp -R . "$out/Applications/RepoPrompt CE.app"

    # Extract original entitlements so they survive re-signing.
    /usr/bin/codesign -d --entitlements :"$TMPDIR/entitlements.plist" \
      "$out/Applications/RepoPrompt CE.app"

    # These two entitlements are tied to the developer's real Apple provisioning
    # profile. Ad-hoc re-signing can't satisfy them, and AMFI SIGKILLs the process
    # at launch if they're left in, so drop them before re-signing.
    /usr/libexec/PlistBuddy -c "Delete :com.apple.application-identifier" "$TMPDIR/entitlements.plist"
    /usr/libexec/PlistBuddy -c "Delete :com.apple.developer.team-identifier" "$TMPDIR/entitlements.plist"

    # Re-sign with ad-hoc signature, preserving entitlements.
    /usr/bin/codesign --force --deep --sign - \
      --entitlements "$TMPDIR/entitlements.plist" \
      "$out/Applications/RepoPrompt CE.app"
    runHook postInstall
  '';

  meta = {
    description = "Context engineering app for AI coding agents";
    homepage = "https://github.com/repoprompt/repoprompt-ce";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}

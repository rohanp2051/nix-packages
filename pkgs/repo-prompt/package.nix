{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

stdenvNoCC.mkDerivation {
  pname = "repo-prompt";
  version = "2.0.10";

  src = fetchurl {
    url = "https://repoprompt.s3.us-east-2.amazonaws.com/RepoPrompt-2.0.10.dmg";
    hash = "sha256-J17QInAzj3q0g3aZgrgZEoq7y9d8g4eV2Hgg0l8nwd4=";
  };

  nativeBuildInputs = [ _7zz ];
  sourceRoot = "Repo Prompt.app";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications/Repo Prompt.app"
    cp -R . "$out/Applications/Repo Prompt.app"

    # 7zz extracts APFS extended attributes as separate files (e.g. "file:com.apple.provenance").
    # These break code signature verification, so remove them.
    find "$out" -name '*:com.apple.*' -delete
    runHook postInstall
  '';

  meta = {
    description = "Generate prompts from your codebase for LLMs";
    homepage = "https://repoprompt.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}

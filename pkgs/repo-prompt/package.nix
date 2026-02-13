{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

stdenvNoCC.mkDerivation {
  pname = "repo-prompt";
  version = "2.0.0";

  src = fetchurl {
    url = "https://repoprompt.s3.us-east-2.amazonaws.com/RepoPrompt-2.0.0.dmg";
    hash = "sha256-E1nVdMfKCXrcV+ZpkTUk0abfxOBqickJf0hi3Fb7yx4=";
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

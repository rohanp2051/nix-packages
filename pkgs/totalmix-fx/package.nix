{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation {
  pname = "totalmix-fx";
  version = "1.99";

  src = fetchurl {
    url = "https://rme-audio.de/downloads/tmfx_mac_199.zip";
    hash = "sha256-PFcNR8ffB47WCLIlpnECUuqqFHajp4RcGMSH/8bdBIk=";
  };

  nativeBuildInputs = [ unzip ];
  sourceRoot = "Totalmix.app";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications/Totalmix.app"
    cp -R . "$out/Applications/Totalmix.app"
    runHook postInstall
  '';

  meta = {
    description = "Mixer application for RME audio interfaces";
    homepage = "https://rme-audio.de/totalmix-fx.html";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}

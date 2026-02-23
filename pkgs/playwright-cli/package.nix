{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchzip,
  linkFarm,
  makeWrapper,
}:

let
  # Browser revisions from playwright-core 1.59.0-alpha-1771104257000 browsers.json
  # Chrome for Testing uses cdn.playwright.dev with browserVersion in the URL
  chromium = fetchzip {
    url = "https://cdn.playwright.dev/builds/cft/146.0.7680.0/mac-arm64/chrome-mac-arm64.zip";
    stripRoot = false;
    hash = "sha256-HtVtipeZYoKdl9JbUUP2dkZu7GTKMLtcbEectWhDObM=";
  };

  chromium-headless-shell = fetchzip {
    url = "https://cdn.playwright.dev/builds/cft/146.0.7680.0/mac-arm64/chrome-headless-shell-mac-arm64.zip";
    stripRoot = false;
    hash = "sha256-c/ZNthHNbX/e6zmC47o7VUqnOHyCMhvH5GD6Q8hpeZA=";
  };

  ffmpeg = fetchzip {
    url = "https://playwright.azureedge.net/builds/ffmpeg/1011/ffmpeg-mac-arm64.zip";
    stripRoot = false;
    hash = "sha256-ky10UQj+XPVGpaWAPvKd51C5brml0y9xQ6iKcrxAMRc=";
  };

  browsers = linkFarm "playwright-browsers" {
    "chromium-1212" = chromium;
    "chromium_headless_shell-1212" = chromium-headless-shell;
    "ffmpeg-1011" = ffmpeg;
  };
in
buildNpmPackage {
  pname = "playwright-cli";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    tag = "v0.1.1";
    hash = "sha256-Ao3phIPinliFDK04u/V3ouuOfwMDVf/qBUpQPESziFQ=";
  };

  npmDepsHash = "sha256-4x3ozVrST6LtLoHl9KtmaOKrkYwCK84fwEREaoNaESc=";
  env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  dontNpmBuild = true;
  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/playwright-cli \
      --set PLAYWRIGHT_BROWSERS_PATH ${browsers}
  '';

  meta = {
    description = "CLI for Playwright browser automation";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource binaryNativeCode ];
    mainProgram = "playwright-cli";
  };
}

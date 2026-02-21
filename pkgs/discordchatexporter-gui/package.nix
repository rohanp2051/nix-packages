{
  lib,
  stdenv,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "discordchatexporter-gui";
  version = "2.46.1";

  src = fetchFromGitHub {
    owner = "Tyrrrz";
    repo = "DiscordChatExporter";
    rev = finalAttrs.version;
    hash = "sha256-8U+/14IBU6Z/DiqekqSexxVKXFIw420kVBn/O0uSeco=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  projectFile = "DiscordChatExporter.Gui/DiscordChatExporter.Gui.csproj";
  nugetDeps = ./deps.json;

  dotnetBuildFlags = [
    "-p:CSharpier_Bypass=true"
    "-p:Deorcify_Bypass=true"
  ];

  dotnetFlags = [ "-p:RuntimeIdentifiers=" ];

  env.AVALONIA_TELEMETRY_OPTOUT = "1";

  postPatch = ''
    # Redirect settings storage from the read-only Nix store to a user-writable
    # location. On macOS, Environment.SpecialFolder.ApplicationData resolves to
    # ~/.config by default in .NET; LocalApplicationData maps to
    # ~/Library/Application Support. We use LocalApplicationData for the macOS
    # convention.
    substituteInPlace DiscordChatExporter.Gui/Services/SettingsService.cs \
      --replace-fail \
        'Path.Combine(AppContext.BaseDirectory, "Settings.dat")' \
        'Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "DiscordChatExporter", "Settings.dat")'
  '';

  dontDotnetFixup = true;

  postFixup =
    ''
      wrapDotnetProgram $out/lib/${finalAttrs.pname}/DiscordChatExporter \
        $out/bin/${finalAttrs.meta.mainProgram}
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications/DiscordChatExporter.app/Contents/{MacOS,Resources}

      cat > $out/Applications/DiscordChatExporter.app/Contents/Info.plist << 'PLIST'
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>CFBundleDisplayName</key>
          <string>DiscordChatExporter</string>
          <key>CFBundleName</key>
          <string>DiscordChatExporter</string>
          <key>CFBundleExecutable</key>
          <string>DiscordChatExporter</string>
          <key>NSHumanReadableCopyright</key>
          <string>© Oleksii Holub</string>
          <key>CFBundleIdentifier</key>
          <string>me.Tyrrrz.DiscordChatExporter</string>
          <key>CFBundleSpokenName</key>
          <string>Discord Chat Exporter</string>
          <key>CFBundleIconFile</key>
          <string>AppIcon</string>
          <key>CFBundleIconName</key>
          <string>AppIcon</string>
          <key>CFBundleVersion</key>
          <string>${finalAttrs.version}</string>
          <key>CFBundleShortVersionString</key>
          <string>${finalAttrs.version}</string>
          <key>NSHighResolutionCapable</key>
          <true />
          <key>CFBundlePackageType</key>
          <string>APPL</string>
        </dict>
      </plist>
      PLIST

      install -Dm444 $src/favicon.icns \
        $out/Applications/DiscordChatExporter.app/Contents/Resources/AppIcon.icns

      ln -s $out/bin/${finalAttrs.meta.mainProgram} \
        $out/Applications/DiscordChatExporter.app/Contents/MacOS/DiscordChatExporter
    '';

  meta = {
    description = "GUI application to export Discord chat logs to a file";
    homepage = "https://github.com/Tyrrrz/DiscordChatExporter";
    license = lib.licenses.gpl3Plus;
    changelog = "https://github.com/Tyrrrz/DiscordChatExporter/blob/${finalAttrs.version}/Changelog.md";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
      binaryNativeCode
    ];
    mainProgram = "discordchatexporter-gui";
  };
})

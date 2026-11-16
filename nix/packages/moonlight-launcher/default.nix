# shamelessly stolen from https://gitlab.com/worldspawn/nix/-/blob/main/packages/moonlight-launcher/default.nix?ref_type=heads
{
  lib,
  fetchFromGitHub,
  pkg-config,
  openssl,
  makeWrapper,
  fenix,
  makeRustPlatform,
}:

let
  toolchain = fenix.toolchainOf {
    channel = "nightly";
    date = "2025-03-01";
    sha256 = "sha256-38THa5qhc9b9KN7PTAumE0AZ4X30pDwYPhKUFDUHY/c=";
  };

  rustPlatform = makeRustPlatform {
    cargo = toolchain.cargo;
    rustc = toolchain.rustc;
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "moonlight-launcher";
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "MeguminSama";
    repo = "moonlight-launcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0MPCXKjvoYT+9XaH/VKhnMpFFFX9iQwL0l/7bN9vqM0=";
  };

  cargoHash = "sha256-8CiZte2qiAEuMz0lMuwRob/Q+CdmWSy6nPUIh1nEkFE=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    openssl
  ];

  env = {
    OPENSSL_NO_VENDOR = "1";
  };

  doCheck = false;

  postPatch = ''
        cp src/bin/{canary,development}.rs
        substituteInPlace src/bin/development.rs \
          --replace-fail '-canary"' '-development"' \
          --replace-fail '::Canary' '::Development' \
          --replace-fail ' Canary"' ' Development"'

        substituteInPlace Cargo.toml \
          --replace-fail 'path = "src/bin/canary.rs"' 'path = "src/bin/canary.rs"

    [[bin]]
    name = "moonlight-development"
    path = "src/bin/development.rs"'

        substituteInPlace src/discord.rs \
          --replace-fail 'let command =' 'let mut command =' \
          --replace-fail '    let command_output =' '    command = name.to_string();
        let command_output ='
  '';

  postInstall = ''
    for bin in $out/bin/moonlight-*; do
      wrapProgram "$bin" \
        --prefix LD_LIBRARY_PATH : "$out/lib"
    done

    install -Dm644 ${./icons/icon-16x16.png}     $out/share/icons/hicolor/16x16/apps/moonlight.png
    install -Dm644 ${./icons/icon-32x32.png}     $out/share/icons/hicolor/32x32/apps/moonlight.png
    install -Dm644 ${./icons/icon-48x48.png}     $out/share/icons/hicolor/48x48/apps/moonlight.png
    install -Dm644 ${./icons/icon-64x64.png}     $out/share/icons/hicolor/64x64/apps/moonlight.png
    install -Dm644 ${./icons/icon-128x128.png}   $out/share/icons/hicolor/128x128/apps/moonlight.png
    install -Dm644 ${./icons/icon-256x256.png}   $out/share/icons/hicolor/256x256/apps/moonlight.png
    install -Dm644 ${./icons/icon-512x512.png}   $out/share/icons/hicolor/512x512/apps/moonlight.png
    install -Dm644 ${./icons/icon-1024x1024.png} $out/share/icons/hicolor/1024x1024/apps/moonlight.png
  '';

  meta = {
    description = "Convenient launcher for moonlight that doesn't modify your Discord install";
    longDescription = ''
      moonlight-launcher runs the moonlight Discord client mod without ever
      patching your Discord installation. It auto-downloads the latest moonlight
      release and injects it at launch time via LD_PRELOAD / Electron hook.

      Three binaries are installed: moonlight-stable, moonlight-ptb, and
      moonlight-canary, one for each Discord release channel. Discord itself
      must be installed separately.

      Pass -- <args> to forward arguments directly to Discord, e.g.:
        moonlight-stable -- --start-minimized
    '';
    homepage = "https://github.com/MeguminSama/moonlight-launcher";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "moonlight-stable";
  };
})

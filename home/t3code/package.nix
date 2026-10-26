{ pkgs, lib, ... }:

let
  version = "0.1.3-nightly.20261023.3553";
  src = pkgs.fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/t3-${version}-linux-x64.tar.gz";
    hash = "sha256-67y+QBpI/fx20/yD/s0IaoYm4QIQnZudLlczNUgJiRU=";
  };

  # Runtime dependencies for T3 Code and dynamically downloaded Chromium (Playwright)
  browserLibraryPath = lib.makeLibraryPath (with pkgs; [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    libgbm
    libxkbcommon
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
  ]);
in
pkgs.stdenv.mkDerivation {
  pname = "t3";
  inherit version src;
  nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
  buildInputs = [ pkgs.stdenv.cc.cc.lib ];
  dontBuild = true;
  dontStrip = true; # Node SEA embeds the application in the executable; stripping corrupts it
  dontPatchELF = true;
  dontAutoPatchelf = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/t3
    cp -r . $out/lib/t3/
    # patchelf >= 0.18 corrupts Node SEA binaries (postject) when modifying RPATH/DYNAMIC,
    # creating overlapping LOAD segments that cause ld-linux to segfault in dl_main.
    # Only set the ELF interpreter on t3 and rely on makeWrapper's LD_LIBRARY_PATH for libs.
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/lib/t3/t3
    autoPatchelf $out/lib/t3/resource-monitor $out/lib/t3/node_modules
    makeWrapper $out/lib/t3/t3 $out/bin/t3 \
      --prefix PATH : ${lib.makeBinPath [ pkgs.git pkgs.openssh pkgs.nodejs_24 pkgs.coreutils pkgs.opencode pkgs.python3 pkgs.cacert ]} \
      --prefix LD_LIBRARY_PATH : ${browserLibraryPath} \
      --set-default SSL_CERT_FILE "/etc/ssl/certs/ca-certificates.crt" \
      --set-default NIX_SSL_CERT_FILE "/etc/ssl/certs/ca-certificates.crt" \
      --set-default SSL_CERT_DIR "/etc/ssl/certs" \
      --set-default REQUESTS_CA_BUNDLE "/etc/ssl/certs/ca-certificates.crt"
    runHook postInstall
  '';
  meta = with lib; {
    description = "T3 Code - Nightly release from GitHub Releases";
    homepage = "https://t3.codes";
    platforms = [ "x86_64-linux" ];
  };
}

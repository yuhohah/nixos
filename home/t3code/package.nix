{ pkgs, lib, ... }:

let
  version = "0.0.46-nightly.20261014.3105";
  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@t3code/t3-linux-x64/-/t3-linux-x64-${version}.tgz";
    hash = "sha256-IMHH3f2XI614HHkovK/GwtOCoN7TVC5QwRRC76owSi0=";
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
  dontStrip = true; # Bun embeds the application in the executable; stripping corrupts it
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/t3
    cp -r . $out/lib/t3/
    makeWrapper $out/lib/t3/t3 $out/bin/t3 \
      --prefix PATH : ${lib.makeBinPath [ pkgs.git pkgs.openssh pkgs.nodejs_24 pkgs.coreutils pkgs.opencode ]} \
      --prefix LD_LIBRARY_PATH : ${browserLibraryPath}
    runHook postInstall
  '';
  meta = with lib; {
    description = "T3 Code - Nightly release from NPM";
    homepage = "https://t3.codes";
    platforms = [ "x86_64-linux" ];
  };
}

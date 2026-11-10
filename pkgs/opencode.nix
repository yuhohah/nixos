{ lib, stdenvNoCC, stdenv, fetchurl, autoPatchelfHook, makeWrapper, ripgrep, wayland, writableTmpDirAsHomeHook }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode";
  version = "2.2.7";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${finalAttrs.version}/opencode-linux-x64.tar.gz";
    hash = "sha256-iabO4ie1S8ARF5xSil5jF2AyRisaXiFyO2FoAc3cLKc=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ stdenv.cc.cc.lib ];
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 opencode $out/bin/opencode
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/opencode \
      --set OPENCODE_DISABLE_AUTOUPDATE true \
      --suffix PATH : ${lib.makeBinPath [ ripgrep ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ stdenv.cc.cc.lib wayland ]}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ writableTmpDirAsHomeHook ];
  installCheckPhase = ''
    runHook preInstallCheck
    opencodeCheckDir=$(mktemp -d)
    export XDG_DATA_HOME="$opencodeCheckDir/data"
    export XDG_CONFIG_HOME="$opencodeCheckDir/config"
    export XDG_CACHE_HOME="$opencodeCheckDir/cache"
    export XDG_STATE_HOME="$opencodeCheckDir/state"
    export OPENCODE_DISABLE_MODELS_FETCH=true
    test "$(TMPDIR="$opencodeCheckDir" $out/bin/opencode --version)" = "opencode v${finalAttrs.version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "AI coding agent built for the terminal";
    homepage = "https://github.com/anomalyco/opencode";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "opencode";
  };
})

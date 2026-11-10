{ lib, stdenvNoCC, fetchurl, autoPatchelfHook }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "codex";
  version = "0.167.1";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${finalAttrs.version}/codex-package-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-qUXfPfg+hJ3Xt0eH4n+KRZwZRrDjr+Pcju+KjRhF/U8=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook ];
  dontBuild = true;
  dontStrip = true;

  # Preserve the official layout, including sandbox, code-mode and voice helpers.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -a bin codex-package.json codex-path codex-resources $out/
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test "$($out/bin/codex --version)" = "codex-cli ${finalAttrs.version}"
    $out/bin/codex app-server --help >/dev/null
    $out/codex-path/rg --version >/dev/null
    $out/codex-resources/bwrap --version >/dev/null
    $out/codex-resources/voice/bin/codex-voice-host --build-commit >/dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "OpenAI coding agent with its official runtime helpers";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "codex";
  };
})

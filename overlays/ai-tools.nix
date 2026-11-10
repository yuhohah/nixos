final: prev: {
  codex = final.callPackage ../pkgs/codex.nix { };
  opencode = final.callPackage ../pkgs/opencode.nix { };

  antigravity-ide = prev.antigravity-ide.overrideAttrs {
    version = "2.6.0";
    src = final.fetchurl {
      url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.6.0-5526304964083712/linux-x64/Antigravity%20IDE.tar.gz";
      hash = "sha256-sGCnx2eRA7K2GXUvjuejCI3SQafSB9QxGXS1bqb5Q1Y=";
    };
  };
}

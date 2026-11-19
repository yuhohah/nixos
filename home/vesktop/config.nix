{ ... }:

{
  home.file.".config/vesktop/settings.json".text = builtins.toJSON {
    audioSharingEnabled = true;
    preferredCaptureDevice = "pipewire";
    minimizeToTray = true;
    discordBranch = "stable";
  };
}
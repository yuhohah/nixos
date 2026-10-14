# agenix recipients — who can decrypt each secret.
# NOT imported by the NixOS config; used only by the `agenix` CLI:
#   cd ~/Configuration/nixos/secrets && agenix -e omniroute-api-key.age
#
# Secrets are decrypted at login by the Home Manager agenix module
# (home/secrets/default.nix) using ~/.ssh/id_ed25519.
let
  luan-arrow = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWIovLxUNhoNHtYwSVduhurWeQkttct4dOrNALPrhNB luan@arrow";
  luan-nixos-btw = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAFLkwSZo+6o951tDjYkAYW8khMXzFccWAtN5lMpVwp luan@nixos-btw";

  users = [ luan-arrow luan-nixos-btw ];
in
{
  # OpenCode -> OmniRoute API key (generated in the OmniRoute dashboard).
  "omniroute-api-key.age".publicKeys = users;

  # OmniRoute server env file (JWT_SECRET, API_KEY_SECRET, INITIAL_PASSWORD, ...).
  "omniroute-env.age".publicKeys = users;
}

# agenix recipients — who can decrypt each secret.
# NOT imported by the NixOS config; used only by the `agenix` CLI:
#   cd ~/Configuration/nixos/secrets && agenix -e <secret>.age
#
# Secrets are decrypted at login by the Home Manager agenix module
# (home/secrets/default.nix) using ~/.ssh/id_ed25519.
let
  luan-arrow = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWIovLxUNhoNHtYwSVduhurWeQkttct4dOrNALPrhNB luan@arrow";
  luan-nixos-btw = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAFLkwSZo+6o951tDjYkAYW8khMXzFccWAtN5lMpVwp luan@nixos-btw";

  users = [ luan-arrow luan-nixos-btw ];
in
{
  # Example: "my-secret.age".publicKeys = users;
}

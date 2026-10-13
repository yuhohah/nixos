# agenix recipients — who can decrypt each secret.
# NOT imported by the NixOS config; used only by the `agenix` CLI:
#   cd ~/Configuration/nixos/secrets && agenix -e omniroute-api-key.age
#
# Secrets are decrypted at login by the Home Manager agenix module
# (home/secrets/default.nix) using ~/.ssh/id_ed25519.
let
  luan-arrow = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWIovLxUNhoNHtYwSVduhurWeQkttct4dOrNALPrhNB luan@arrow";
  # TODO: add luan's ~/.ssh/id_ed25519.pub from nixos-btw, then run `agenix -r`.
  # luan-nixos-btw = "ssh-ed25519 AAAA... luan@nixos-btw";

  users = [ luan-arrow ];
in
{
  # OpenCode -> OmniRoute API key (generated in the OmniRoute dashboard).
  "omniroute-api-key.age".publicKeys = users;

  # OmniRoute server env file (JWT_SECRET, API_KEY_SECRET, INITIAL_PASSWORD, ...).
  "omniroute-env.age".publicKeys = users;
}

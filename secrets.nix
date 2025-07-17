# Not imported, used by Agenix to encrypt secrets
let
  # Import our keys from our secrets-flake
  publicKeys = (builtins.getFlake "git+https://git.irlqt.net/crow/secrets-flake").publicKeys;
in
{
  # Cloudflare DNS Token
  "secrets/cloudflare-dns.token".publicKeys = [ publicKeys.machines.lighthouse publicKeys.machines.spark publicKeys.machines.archive ];
}

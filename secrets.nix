# Not imported, used by Agenix to encrypt secrets
let
  # Import our keys from our secrets-flake
  publicKeys = (builtins.getFlake "git+https://git.irlqt.net/crow/secrets-flake").publicKeys.machines;
in
{
  # Cloudflare DNS Token
  "secrets/cloudflare-dns.token".publicKeys = [ publicKeys.lighthouse publicKeys.archive publicKeys.tavern ];
}

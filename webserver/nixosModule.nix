{
  lib,
  pkgs,
  config,
  options,
  sops-nix,
  sites,
  ...
}: let
  # Check that the web-server is enabled at the top before proceeding
  cfgCheck = config.websites.enable;
# websites = ["homepage"];
# website_options =
#   builtins.listToAttrs
#   (builtins.map (u: {
#       name = u;
#       value = {enable = lib.mkEnableOption "${u}";};
#     })
#     websites);
in {
  # Import the modules per website
  # Import the Sops-Nix module to ensure we can decrypt keys for certificate setting
# imports =
#   (builtins.map
#     (u: ./${u}.nix)
#     websites)
#   ++ [sops-nix.nixosModules.sops];
    imports = [sops-nix.nixosModules.sops];

  # Add options to enable each website if the web-server is enabled
# options = {
#   websites = {
#     sites = lib.mkIf cfgCheck website_options;
#   };
# };

  throw "gay girls";
  # Configure the web-server, certificates, and secrets if enabled
  config = lib.mkIf cfgCheck {
    services = {
      # Enable a web-server and reverse proxy with some sensible defaults
      nginx = {
        enable = true;

        # Use the recommended settings
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;

        # 500Mib Max Uploads
        clientMaxBodySize = "500m";
        # Convenient global expiry by content type map
        commonHttpConfig = ''
          map $sent_http_content_type $expires {
            default off;
            text/html 1d;
            text/css 1d;
            applications/javascript 1d;
            ~image/ max;
            application/manifest+json 7d;
          }
        '';
      };
    };

    # Set up our certificates
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = lib.mkDefault "accounts@xvrqt.com";
        dnsProvider = lib.mkDefault "cloudflare";
        dnsResolver = lib.mkDefault "1.1.1.1:53";
        environmentFile = lib.mkDefault null;
        credentialFiles = lib.mkDefault {
          CF_DNS_API_TOKEN_FILE = config.sops.secrets."cloudflare/CF_DNS_API_TOKEN".path;
        };
      };
    };

    # 'acme' needs to own the file so it can access the secret
    sops.secrets."cloudflare/CF_DNS_API_TOKEN" = {owner = "acme";};
  };
}

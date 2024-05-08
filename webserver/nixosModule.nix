{
  lib,
  pkgs,
  config,
  ...
}: let
  # Check that the web-server is enabled at the top before proceeding
  cfgCheck = config.websites.enable;
in {
  config = lib.mkIf cfgCheck {
    services = {
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
        email = "accounts@xvrqt.com";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        environmentFile = null;
        credentialFiles = {
          CF_DNS_API_TOKEN_FILE = config.sops.secrets."cloudflare/CF_DNS_API_TOKEN".path;
        };
      };
    };
    # 'acme' needs to own the file so it can access the secret
    sops.secrets."cloudflare/CF_DNS_API_TOKEN" = {owner = "acme";};
  };
}

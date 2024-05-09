{
  lib,
  config,
  ...
}: let
  # Check that the web-server is enabled at the top before proceeding
  cfgCheck = config.services.websites.enable;
  # Set the correct ACME attribute set depending on DNS Provider
  acmeAttrSet =
    if config.services.websites.dnsProvider == "cloudflare"
    then {
      acceptTerms = lib.mkDefault true;
      defaults = {
        email = lib.mkDefault config.services.websites.email;
        dnsProvider = lib.mkDefault "cloudflare";
        dnsResolver = lib.mkDefault "1.1.1.1:53";
        environmentFile = lib.mkDefault null;
        credentialFiles = lib.mkDefault {
          CF_DNS_API_TOKEN_FILE = lib.mkDefault config.services.websites.dnsTokenFile;
        };
      };
    }
    else {}; # Only cloudflare is implemented because that's the only one I use at the moment
in {
  # Create an option to provide a security token from a file
  options = {
    services = {
      websites = {
        # Which DNS Provider should ACME use when issuing its certificates
        dnsProvider = lib.mkOption {
          type = lib.types.str;
          default = "cloudflare";
          description = "The DNS Provider ACME will use to confirm ownership of a domain name when issuing certificates.";
          example = "\"cloudflare\"";
        };
        email = lib.mkOption {
          type = lib.types.str;
          default = "accounts@xvrqt.com";
          example = "myemail@provider.com";
          description = "Email used for your DNS Provider account";
        };
        # Secret token required for the ACME certificate challenge
        dnsTokenFile = lib.mkOption {
          type = lib.types.path;
          description = "Path to a file that contains a secrety token used to authenticate with a DNS provider for the purpose of auto generating certificates.";
        };
      };
    };
  };

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

    # Set up our certificate challenge based on the declared DNS Provider;
    security.acme = acmeAttrSet;
  };
}

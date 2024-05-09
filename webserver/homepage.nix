{
  lib,
  pkgs,
  config,
  ...
}: let
  cfgCheck = config.websites.sits.homepage.enable;
in {
  # Create a derivation we can link to
  nixpkgs.overlays = final: prev: {
    homepage = final.stdenv.mkDerivation {
      name = "website-homepage";
      src = prev.fetchFromGithub {
        owner = "xvrqt";
        repo = "xvrqt_homepage";
      };
      installPhase = ''
        cp -r src $out
      '';
    };
  };

  # Set up the Nginx Virtual Server
  config = lib.mkIf cfgCheck {
    services.nginx = {
      virtualHosts."xvrqt.com" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null;

        extraConfig = ''
          charset utf-8;
          etag on;
          index index.html;
          http2_push_preload on;
          expires $expires;
        '';

        locations."/" = {
          root = "/var/www/xvrqt/src";

          extraConfig = ''
            try_files $uri $uri/ =404;

            http2_push /styles.css;
            http2_push /images/xvrqt.webp;
            http2_push /images/xvrqt.png;
            http2_push /images/title/xvrqt@3x.webp;
            http2_push /images/title/xvrqt@3x.png;
            http2_push /images/bg@2x.png;
          '';
        };
      };
    };
  };
}

{
  inputs = {
    # Used to store and retrieve encrypted DNS challenge tokens
    secrets.url = "git+https://git.irlqt.net/crow/secrets-flake";

    # Used for building the site
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Websites
    cs4600.url = "git+https://git.irlqt.net/crow/cs4600-website-flake";
    dino-game.url = "git+https://git.irlqt.net/crow/dino-website-flake";
    game-of-life.url = "git+https://git.irlqt.net/crow/gol-website-flake";
    homepage.url = "git+https://git.irlqt.net/crow/homepage-website-flake";
    http.url = "git+https://git.irlqt.net/crow/http-status-codes-website";
    moomin-orb.url = "git+https://git.irlqt.net/crow/moomin-orb-website-flake";
    irlqt-net.url = "git+https://git.irlqt.net/crow/irlqt-net-website-flake";
    moshimom.url = "git+https://git.irlqt.net/crow/moshi-mom-website-flake";
  };

  outputs = { utils, nixpkgs, secrets, ... } @ sites:
    let
      wrapped = utils.lib.eachDefaultSystem
        (system:
          {
            nixosModules = {
              default = {
                imports = [
                  # Allows for use of secrets in the NixOS Module below
                  secrets.nixosModules.default
                  # Main option to enable the websites
                  # Imports submodules: webserver (enables nginx, configures auto fetching certificates)
                  ./nixosModule.nix

                  # Import individual sites
                  # Each site
                  #   - creates an option under: services.websites.sites.<site>
                  #   - configures a virtual host for nginx
                  #   - creates a package and installs itself
                  sites.cs4600.nixosModules.default # cs4600 class projects
                  sites.dino-game.nixosModules.default # A game with dinosaurs
                  sites.homepage.nixosModules.default # xvrqt homepage
                  sites.http.nixosModules.default # A site that generates HTTP status codes

                  sites.irlqt-net.nixosModules.default # cs4600 class projects
                  sites.moshimom.nixosModules.default # My daughter's mother

                  sites.moomin-orb.nixosModules.default # View images in Moomin's Orb
                  sites.game-of-life.nixosModules.${system}.default
                ];
              };
            };
          });
      nixosModules = wrapped.nixosModules // rec {
        # Only the reverse proxy setup and nothing else
        reverseProxy = {
          imports = [
            secrets.nixosModules.default
            ./nixosModule.nix
          ];
        };
        minimal = reverseProxy;

        # Allows caller to include sites individually
        inherit sites;
      };
    in
    {
      inherit nixosModules;
    };
}

# Convenience function to setup a simple reverse proxy
#   setupReverseProxy = { domain, proxy_socket }: {
#     config.services.nginx.virtualHosts.${domain} = {
#       forceSSL = true;
#       acmeRoot = null;
#       enableACME = true;

#       locations."/" = {
#         proxyPass = proxy_socket;
#         proxyWebsockets = true;
#         recommendedProxySettings = true;
#       };
#     };
#   };

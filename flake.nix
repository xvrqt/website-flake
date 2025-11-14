{
  inputs = {
    # Used to store and retrieve encrypted DNS challenge tokens
    secrets.url = "git+https://git.irlqt.net/crow/secrets-flake";

    # Used for building the site
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Websites
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

{
  inputs = {
    # Websites
    homepage.url = "github:xvrqt/xvrqt_homepage/deploy";
    cs4600.url = "github:xvrqt/cs4600/deploy";
    moomin-orb.url = "github:xvrqt/moomin-orb/deploy";
  };

  outputs = {...} @ sites: let
  in {
    nixosModules = {
      default = {
        imports = [
          # Main option to enable the websites
          # Imports submodules: webserver (enables nginx, configures auto fetching certificates)
          ./nixosModule.nix

          # Import individual sites
          # Each site
          #   - creates an option under: services.websites.sites.<site>
          #   - configures a virtual host for nginx
          #   - creates a package and installs itself
          sites.homepage.nixosModules.default # xvrqt homepage
          sites.cs4600.nixosModules.default # cs4600 class projects
          sites.moomin-orb.nixosModules.default # View images in Moomin's Orb
        ];
      };
    };
  };
}

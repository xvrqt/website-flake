{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    # Websites
    homepage.url = "github:xvrqt/xvrqt_homepage/deploy";
    dino-game.url = "github:xvrqt/dino-game";
    cs4600.url = "github:xvrqt/cs4600/deploy";
    moomin-orb.url = "github:xvrqt/moomin-orb/deploy";
    game-of-life.url = "github:xvrqt/game-of-life-demo/deploy";
    graphics.url = "github:xvrqt/graphics-website";
  };

  outputs = {flake-utils, ...} @ sites:
    flake-utils.lib.eachDefaultSystem (system: {
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
            sites.dino-game.nixosModules.default # A game with dinosaurs (static site)
            sites.cs4600.nixosModules.default # cs4600 class projects
            sites.moomin-orb.nixosModules.default # View images in Moomin's Orb
            sites.game-of-life.nixosModules.${system}.default
            sites.graphics.nixosModules.${system}.default
          ];
        };
      };
    });
}

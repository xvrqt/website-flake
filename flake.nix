{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    # Websites
    cs4600.url = "git+https://git.irlqt.net/crow/cs4600-website-flake";
    dino-game.url = "git+https://git.irlqt.net/crow/dino-website-flake";
    game-of-life.url = "git+https://git.irlqt.net/crow/gol-website-flake";
    # homepage.url = "git+https://git.irlqt.net/crow/homepage-website-flake";
    homepage.url = "/home/crow/dev/homepage-website-flake";
    http.url = "git+https://git.irlqt.net/crow/http-status-codes-website";
    moomin-orb.url = "git+https://git.irlqt.net/crow/moomin-orb-website-flake";
  };

  outputs = { flake-utils, ... } @ sites:
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
            sites.cs4600.nixosModules.default # cs4600 class projects
            sites.dino-game.nixosModules.default # A game with dinosaurs (static site)
            sites.game-of-life.nixosModules.${system}.default # Showcase of the Game of Life with WASM and WebGL
            sites.homepage.nixosModules.default # xvrqt homepage
            sites.http.nixosModules.default # A site that generates HTTP status codes
            sites.moomin-orb.nixosModules.default # View images in Moomin's Orb
            sites.game-of-life.nixosModules.${system}.default
          ];
        };
      };
    });
}

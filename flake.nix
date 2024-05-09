{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    sops-nix.url = "github:Mic92/sops-nix";

    # Websites
    homepage.url = "/var/www/xvrqt";
  };

  outputs = {sops-nix, ...} @ sites: {
    nixosModules = {
      default = {
        lib,
        pkgs,
        config,
	options,
        sops-nix,
        sites,
        ...
      }: {
        imports = [
          ./nixosModule.nix 
          #sites.homepage.nixosModules.default
	];
      };
    };
  };
}

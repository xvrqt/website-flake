# Websites
A flake which configures a web-server, certificates, and deploys included websites.
## Installation
Add this flake to your NixOS Configuration list of modules flake inputs, and add its NixOS Module to the outputs:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs";
    websites.url = "github:xvrqt/website-flake";
    # etc...
  };

  outputs = {web, ...} @ inputs: let
    pkgs = import nixpkgs {
      system = "my_system";
    };   
  in
  {
      nixos-configuration = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = { inherit inputs; };
        modules = [
          websites.nixosModules.default  # <-- Important Bit
          ./my-nix-confiugraion.nix
          # etc...
        ];
      };
  };
}
```
## Options
Once included as a module in your NixOS Configuration, you can set the following options in your own NixOS Module. 
```nix
services = {
  websites = {
    enable = true;

    # Set up DNS Provider details to allow certificates to be generated for TLS
    email = "my@email.com";
    dnsProvider = "cloudflare";
    dnsTokenFile = ./path/to/secret;

    # Enable every site that you want to be active, and optionally set a domain to serve it on
    sites = {
      homepage = {
        enable = true;
        domain = "xvrqt.com";
      };
    };
  };
};
```

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = {sops-nix, ...}: {
    nixosModules = {
      default = import ./nixosModule.nix;
    };
  };
}

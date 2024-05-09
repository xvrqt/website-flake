{lib, options, ...}: let
  # Used to generate the list of nixosModules to import
  submodules = ["webserver"];
  # Convenience function that creates an 'enable' options that defaults to 'true'
  mkEnabled = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  # Generate our import list
  imports =
    builtins.map
    (u: ./${u}/nixosModule.nix)
    submodules;
in {
  throw "gay";
  inherit imports;

  

  # Top level options
  options = {
    services = {
    websites = {
      # Enable the web-server by default (otherwise, why even include this module?)
      # If this isn't enabled none of the other options will have an effect.
#      enable = mkEnabled;
    };
  };
  };
}

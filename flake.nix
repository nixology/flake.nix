{
  description = "A collection of flake components for various purposes.";

  inputs.core.url = "github:nixology/core.nix";

  outputs =
    inputs: with inputs.core.lib; mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}

local@{ ... }:
let
  implementation = local.config.partitions.development.extraInputs.treefmt.flakeModule;

  partitionedImplementation = {
    partitions.development.module = implementation;
  };
in
{
  imports = [
    partitionedImplementation
  ];

  flake.components = {
    nixology.tools.treefmt = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.extra.shellEnvs
        nixology.flake.checks
        nixology.flake.formatter
        nixology.systems.default
      ];

      meta = {
        description = "Integrate treefmt-nix formatting checks and formatter outputs.";
        shortDescription = "treefmt tooling";
      };
    };
  };
}

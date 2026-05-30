{ config, inputs, ... }:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;

  implementation = {
    imports = [
      inputs.core.inputs.flake-parts.flakeModules.bundlers
    ];

    config.flake.schemas = {
      inherit (flake-schemas.schemas) bundlers;
    };
  };

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-flake-bundlers";
        component = with inputs.self.components; nixology.flake.bundlers;
        inherit config;
      };
    };
in
{
  imports = [
    check
  ];

  flake.components = {
    nixology.flake.bundlers = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.core.transposition
      ];

      meta = {
        description = "Provide support for flake `bundlers` outputs and their schema.";
        shortDescription = "flake bundlers";
      };
    };
  };
}

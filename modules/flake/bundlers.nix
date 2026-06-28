local@{ ... }:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  implementation = {
    imports = [
      local.inputs.core.inputs.flake-parts.flakeModules.bundlers
    ];

    config.flake.schemas = {
      inherit (flake-schemas.exportedSchemas) bundlers;
    };
  };

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-flake-bundlers";
        component = nixology.flake.bundlers;
        inherit (module) config;
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

      dependencies = [
        nixology.core.transposition
      ];

      meta = {
        description = "Provide support for flake `bundlers` outputs and their schema.";
        shortDescription = "flake bundlers";
      };
    };
  };
}

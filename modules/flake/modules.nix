local@{ ... }:
let
  inherit (local.inputs.self.components) nixology;

  implementation = {
    imports = [
      local.inputs.core.inputs.flake-parts.flakeModules.modules
    ];

    config.flake.schemas.modules = schema;
  };

  schema = {
    version = 1;
    doc = ''
      The `modules` flake output contains modules for any module system.
    '';
    inventory = _output: {
      what = "modules for use by other module systems";
    };
  };
in
{
  imports = [
    implementation
  ];

  flake.components = {
    nixology.flake.modules = {
      inherit implementation;

      dependencies = [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide the `modules` flake output for modules usable by any module system.";
        shortDescription = "generic modules";
      };
    };
  };
}

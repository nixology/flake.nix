local@{ ... }:
let
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
  flake.components = {
    nixology.flake.modules = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide the `modules` flake output for modules usable by any module system.";
        shortDescription = "generic modules";
      };
    };
  };
}

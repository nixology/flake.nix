local@{ ... }:
let
  implementation = {
    imports = [
      local.inputs.core.inputs.flake-parts.flakeModules.flakeModules
    ];

    config.flake.schemas.flakeModules = schema;
  };

  schema = {
    version = 1;
    doc = ''
      The `flakeModules` flake output contains flake-parts modules for use by other flakes.
    '';
    inventory = _output: {
      what = "flake-parts modules for use by other flakes";
    };
  };
in
{
  flake.components = {
    nixology.flake.flakeModules = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide the `flakeModules` flake output for reusable flake-parts modules.";
        shortDescription = "flake-parts modules";
      };
    };
  };
}

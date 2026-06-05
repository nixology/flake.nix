{ inputs, ... }:
let
  implementation = inputs.core.inputs.flake-parts.flakeModules.easyOverlay;

  check =
    { config, ... }:
    {
      perSystem = config.flake.lib.mkComponentCheck {
        name = "nixology-extra-easyOverlay";
        component = with inputs.self.components; nixology.extra.easyOverlay;
        inherit config;
      };
    };
in
{
  imports = [
    check
  ];

  flake.components = {
    nixology.extra.easyOverlay = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.flake.overlays
      ];

      meta = {
        description = "Expose the upstream flake-parts easyOverlay module as a nixology component.";
        shortDescription = "easy overlay management";
      };
    };
  };
}

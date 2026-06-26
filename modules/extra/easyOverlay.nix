local@{ ... }:
let
  implementation = local.inputs.core.inputs.flake-parts.flakeModules.easyOverlay;

  check =
    module@{ ... }:
    {
      perSystem = local.config.flake.lib.mkComponentCheck {
        name = "nixology-extra-easyOverlay";
        component = with local.inputs.self.components; nixology.extra.easyOverlay;
        inherit (module) config;
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

      dependencies = with local.inputs.self.components; [
        nixology.flake.overlays
      ];

      meta = {
        description = "Expose the upstream flake-parts easyOverlay module as a nixology component.";
        shortDescription = "easy overlay management";
      };
    };
  };
}

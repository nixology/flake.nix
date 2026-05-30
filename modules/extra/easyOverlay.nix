{ inputs, ... }:
let
  implementation = inputs.core.inputs.flake-parts.flakeModules.easyOverlay;
in
{
  flake.components = {
    nixology.extra.easyOverlay = {
      inherit implementation;

      meta = {
        description = "Expose the upstream flake-parts easyOverlay module as a nixology component.";
        shortDescription = "easy overlay management";
      };
    };
  };
}

{ ... }@local:
let
  inherit (local.inputs) core self;
  inherit (self.components) nixology;
in
{
  flake.lib = core.lib.extend (
    _final: prev: {
      parts.mkFlake =
        args: module:
        prev.mkFlake args {
          imports = [
            module
          ]
          ++ [
            (core.lib.components.uses {
              components = [
                nixology.flake.apps
                nixology.flake.checks
                nixology.flake.devShells
                nixology.flake.formatter
                nixology.flake.legacyPackages
                nixology.flake.nixosConfigurations
                nixology.flake.nixosModules
                nixology.flake.overlays
                nixology.flake.packages
              ];
            })
          ];
        };
    }
  );
}

local@{ ... }:
let
  inherit (local.lib)
    mkOption
    types
    ;

  inherit (types)
    lazyAttrsOf
    literalExpression
    raw
    ;

  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  implementation = {
    options.flake.darwinConfigurations = mkOption {
      type = lazyAttrsOf raw;
      default = { };
      description = ''
        Instantiated Darwin configurations. Used by `darwin-rebuild`.

        `darwinConfigurations` is for specific machines. For reusable
        configurations, expose modules through `darwinModules` instead.
      '';
      example = literalExpression ''
        {
          my-machine = inputs.nix-darwin.lib.darwinSystem {
            modules = [ ./configuration.nix ];
            specialArgs = { inherit inputs; };
          };
        }
      '';
    };

    config.flake.schemas = {
      inherit (flake-schemas.exportedSchemas) darwinConfigurations;
    };
  };
in
{
  flake.components = {
    nixology.flake.darwinConfigurations = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide instantiated Darwin configurations for `darwin-rebuild`.";
        shortDescription = "darwin configurations";
      };
    };
  };
}

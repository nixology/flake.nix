{ config, inputs, ... }:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;

  implementation =
    { lib, ... }:
    {
      options.flake.darwinConfigurations = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
        description = ''
          Instantiated Darwin configurations. Used by `darwin-rebuild`.

          `darwinConfigurations` is for specific machines. For reusable
          configurations, expose modules through `darwinModules` instead.
        '';
        example = lib.literalExpression ''
          {
            my-machine = inputs.nix-darwin.lib.darwinSystem {
              modules = [ ./configuration.nix ];
              specialArgs = { inherit inputs; };
            };
          }
        '';
      };

      config.flake.schemas = {
        inherit (flake-schemas.schemas) darwinConfigurations;
      };
    };
in
{
  flake.components = {
    nixology.flake.darwinConfigurations = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide instantiated Darwin configurations for `darwin-rebuild`.";
        shortDescription = "darwin configurations";
      };
    };
  };
}

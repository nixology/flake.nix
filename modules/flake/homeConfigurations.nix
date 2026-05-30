{ config, inputs, ... }:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;

  implementation =
    { lib, ... }:
    {
      options.flake.homeConfigurations = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
        description = ''
          Instantiated Home Manager configurations. Used by `home-manager`.

          `homeConfigurations` is for specific users. For reusable
          configurations, expose modules through `homeModules` instead.
        '';
        example = lib.literalExpression ''
          {
            alice = inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
              modules = [
                inputs.self.homeModules.bash
                {
                  home.username = "alice";
                  home.homeDirectory = "/home/alice";
                  home.stateVersion = "25.11";
                }
              ];
            };
          }
        '';
      };

      config.flake.schemas = {
        inherit (flake-schemas.schemas) homeConfigurations;
      };
    };
in
{
  flake.components = {
    nixology.flake.homeConfigurations = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide instantiated Home Manager configurations for specific users.";
        shortDescription = "home manager configurations";
      };
    };
  };
}

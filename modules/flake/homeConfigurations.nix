local@{ ... }:
let
  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  implementation =
    with local.lib;
    with types;
    {
      options.flake.homeConfigurations = mkOption {
        type = lazyAttrsOf raw;
        default = { };
        description = ''
          Instantiated Home Manager configurations. Used by `home-manager`.

          `homeConfigurations` is for specific users. For reusable
          configurations, expose modules through `homeModules` instead.
        '';
        example = literalExpression ''
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

      dependencies = with local.inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide instantiated Home Manager configurations for specific users.";
        shortDescription = "home manager configurations";
      };
    };
  };
}

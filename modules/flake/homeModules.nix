local@{ ... }:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.lib)
    mapAttrs
    mkOption
    types
    ;

  inherit (types)
    lazyAttrsOf
    deferredModule
    literalExpression
    ;

  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;
  moduleLocation = "${local.inputs.self.outPath}/flake.nix";

  implementation = {
    options.flake.homeModules = mkOption {
      type = lazyAttrsOf deferredModule;
      default = { };

      apply = mapAttrs (
        name: module: {
          _class = "home";
          _file = "${moduleLocation}#homeModules.${name}";
          imports = [ module ];
        }
      );

      description = ''
        Home Manager modules.

        Use this for reusable Home Manager configuration, service modules, and
        other home-manager modules.
      '';

      example = literalExpression ''
        {
          bash = { pkgs, ... }: {
            programs.bash = {
              enable = true;
              shellAliases.ll = "ls -l";
            };

            home.packages = [ pkgs.hello ];
          };
        }
      '';
    };

    config.flake.schemas = {
      inherit (flake-schemas.exportedSchemas) homeModules;
    };
  };
in
{
  flake.components = {
    nixology.flake.homeModules = {
      inherit implementation;

      dependencies = [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide reusable Home Manager modules through the `homeModules` flake output.";
        shortDescription = "home manager modules";
      };
    };
  };
}

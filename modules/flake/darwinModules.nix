local@{ ... }:
let
  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;
  moduleLocation = "${local.inputs.self.outPath}/flake.nix";

  implementation =
    with local.lib;
    with types;
    {
      options.flake.darwinModules = mkOption {
        type = lazyAttrsOf deferredModule;
        default = { };

        apply = mapAttrs (
          name: module: {
            _class = "darwin";
            _file = "${moduleLocation}#darwinModules.${name}";
            imports = [ module ];
          }
        );

        description = ''
          Darwin modules.

          Use this for reusable Darwin configuration, service modules, and
          other nix-darwin modules.
        '';

        example = literalExpression ''
          {
            configuration = { pkgs, ... }: {
              environment.systemPackages = [
                pkgs.vim
                pkgs.wget
              ];

              programs.zsh.enable = true;
            };
          }
        '';
      };

      config.flake.schemas = {
        inherit (flake-schemas.exportedSchemas) darwinModules;
      };
    };
in
{
  flake.components = {
    nixology.flake.darwinModules = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide reusable nix-darwin modules through the `darwinModules` flake output.";
        shortDescription = "darwin modules";
      };
    };
  };
}

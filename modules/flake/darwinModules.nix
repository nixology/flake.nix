{ config, inputs, ... }:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;
  moduleLocation = "${inputs.self.outPath}/flake.nix";

  implementation =
    { lib, ... }:
    {
      options.flake.darwinModules = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.deferredModule;
        default = { };

        apply = lib.mapAttrs (
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

        example = lib.literalExpression ''
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
        inherit (flake-schemas.schemas) darwinModules;
      };
    };
in
{
  flake.components = {
    nixology.flake.darwinModules = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide reusable nix-darwin modules through the `darwinModules` flake output.";
        shortDescription = "darwin modules";
      };
    };
  };
}

{ config, inputs, ... }:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;
  moduleLocation = "${inputs.self.outPath}/flake.nix";

  implementation =
    { lib, ... }:
    {
      options.flake.homeModules = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.deferredModule;
        default = { };

        apply = lib.mapAttrs (
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

        example = lib.literalExpression ''
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
        inherit (flake-schemas.schemas) homeModules;
      };
    };
in
{
  flake.components = {
    nixology.flake.homeModules = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide reusable Home Manager modules through the `homeModules` flake output.";
        shortDescription = "home manager modules";
      };
    };
  };
}

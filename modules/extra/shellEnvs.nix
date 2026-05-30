{ inputs, ... }:
let
  implementation =
    { flake-parts-lib, lib, ... }:
    {
      options.perSystem = flake-parts-lib.mkPerSystemOption (
        { pkgs, ... }:
        {
          options.shellEnvs = lib.mkOption {
            type = lib.types.lazyAttrsOf (
              lib.types.submodule {
                options = {
                  inputsFrom = lib.mkOption {
                    type = lib.types.listOf lib.types.package;
                    default = [ ];
                    description = "Packages whose inputs and shell hooks are included.";
                  };

                  mkShellOverrides = lib.mkOption {
                    type = lib.types.lazyAttrsOf lib.types.anything;
                    default = { };
                    description = "Overrides applied to `pkgs.mkShell`.";
                  };

                  packages = lib.mkOption {
                    type = lib.types.listOf lib.types.package;
                    default = [ ];
                    description = "Packages to include in the development shell.";
                  };

                  shellHook = lib.mkOption {
                    type = lib.types.lines;
                    default = "";
                    description = "Shell hook script run when entering the shell.";
                  };

                  stdenv = lib.mkOption {
                    type = lib.types.package;
                    default = pkgs.stdenvNoCC;
                    defaultText = lib.literalExpression "pkgs.stdenvNoCC";
                    description = "The stdenv used for the development shell.";
                  };
                };
              }
            );
            default = { };
            description = "Development shell environments.";
          };
        }
      );

      config.perSystem =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        lib.mkIf (config.shellEnvs != { }) {
          devShells = lib.mapAttrs (
            name: shellEnv:
            pkgs.mkShell.override shellEnv.mkShellOverrides {
              inherit name;
              inherit (shellEnv)
                inputsFrom
                packages
                shellHook
                stdenv
                ;
            }
          ) config.shellEnvs;
        };
    };

  partitionedImplementation = {
    partitions.development.module = implementation;
  };
in
{
  imports = [
    partitionedImplementation
  ];

  flake.components = {
    nixology.extra.shellEnvs = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.systems.default
        nixology.flake.devShells
      ];

      meta = {
        description = "Define named development shell environments and expose them as `devShells`.";
        shortDescription = "development shell environments";
      };
    };
  };
}

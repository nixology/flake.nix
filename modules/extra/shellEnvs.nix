local@{ ... }:
let
  inherit (local.lib)
    mapAttrs
    mkIf
    mkOption
    types
    ;

  inherit (types)
    anything
    lazyAttrsOf
    lines
    listOf
    literalExpression
    package
    submodule
    ;

  implementation =
    { flake-parts-lib, ... }:
    {
      options.perSystem = flake-parts-lib.mkPerSystemOption (
        { pkgs, ... }:
        {
          options.shellEnvs = mkOption {
            type = lazyAttrsOf (submodule {
              options = {
                inputsFrom = mkOption {
                  type = listOf package;
                  default = [ ];
                  description = "Packages whose inputs and shell hooks are included.";
                };

                mkShellOverrides = mkOption {
                  type = lazyAttrsOf anything;
                  default = { };
                  description = "Overrides applied to `pkgs.mkShell`.";
                };

                packages = mkOption {
                  type = listOf package;
                  default = [ ];
                  description = "Packages to include in the development shell.";
                };

                shellHook = mkOption {
                  type = lines;
                  default = "";
                  description = "Shell hook script run when entering the shell.";
                };

                stdenv = mkOption {
                  type = package;
                  default = pkgs.stdenvNoCC;
                  defaultText = literalExpression "pkgs.stdenvNoCC";
                  description = "The stdenv used for the development shell.";
                };
              };
            });
            default = { };
            description = "Development shell environments.";
          };
        }
      );

      config.perSystem =
        module@{ pkgs, ... }:
        mkIf (module.config.shellEnvs != { }) {
          devShells = mapAttrs (
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
          ) module.config.shellEnvs;
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

      dependencies = with local.inputs.self.components; [
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

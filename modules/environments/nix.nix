{ inputs, ... }:
let
  implementation = {
    perSystem =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        shellEnvs.nix.packages = [
          pkgs.nix-output-monitor
        ];

        treefmt.programs = {
          nixfmt.enable = lib.mkDefault true;
          deadnix.enable = lib.mkDefault true;
          zizmor.enable = lib.mkDefault true;

          nixf-diagnose = {
            enable = lib.mkDefault true;
            excludes = lib.mkDefault [
              config.treefmt.projectRootFile
            ];
          };

          yamlfmt = {
            enable = lib.mkDefault true;
            settings.formatter = {
              type = "basic";
              retain_line_breaks = true;
              trim_trailing_whitespace = true;
            };
          };
        };
      };
  };

  partitionedImplementation = {
    partitions.development = {
      module = implementation;
    };
  };
in
{
  imports = [
    partitionedImplementation
  ];

  flake.components = {
    nixology.environments.nix = {
      inherit implementation;

      dependencies = with inputs.self.components; [
        nixology.extra.shellEnvs
        nixology.tools.treefmt
      ];

      meta = {
        description = "Provide a Nix development environment with formatting and diagnostic tools.";
        shortDescription = "Nix development environment";
      };
    };
  };
}

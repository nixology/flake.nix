local@{ ... }:
let
  inherit (local.lib)
    mkIf
    ;

  gitHooks = local.config.partitions.development.extraInputs.git-hooks;

  implementation = {
    imports = [
      gitHooks.flakeModule
    ];

    perSystem =
      module@{ ... }:
      let
        cfg = module.config.pre-commit;
      in
      {
        shellEnvs.default = mkIf (cfg.settings.enabledPackages != [ ]) {
          packages = cfg.settings.enabledPackages;
          shellHook = cfg.shellHook;
        };
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
    nixology.tools.git-hooks = {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.extra.shellEnvs
        nixology.systems.default
      ];

      meta = {
        description = "Integrate git-hooks.nix pre-commit hooks with the default development shell.";
        shortDescription = "git hooks tooling";
      };
    };
  };
}

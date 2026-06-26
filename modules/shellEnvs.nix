{
  partitions.development.module = {
    perSystem =
      module@{ ... }:
      {
        shellEnvs.default = module.config.shellEnvs.nix;
      };
  };
}

{
  description = "A flake that provides flake schemas";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    core-flake-schemas.url = "github:nixology/core.nix?dir=partitions/schemas";
    flake-schemas.follows = "core-flake-schemas/flake-schemas";
  };
}

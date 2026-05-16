# nixology/flake

A collection of reusable flake components (built on
[`nixology/core`](https://github.com/nixology/core)).

This flake is itself a `nixology` flake. It exports component modules for common
flake-parts outputs, development tooling, shell environments, flake schemas, and
module aggregation helpers.

## Usage

Add this flake as an input and use `mkFlake` to create your flake outputs,
importing modules using `modulesIn` function.

```nix
{
  inputs.flake.url = "github:nixology/flake.nix";

  outputs =
    inputs: with inputs.flake.lib; mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
```

## Outputs

This flake exposes:

- `components`: reusable nixology components.
- `checks`: `treefmt` and pre-commit checks for supported systems.
- `devShells`: `default` and `nix` development shells.
- `formatter`: the `treefmt` formatter.
- `lib`: core helper functions re-exported from `nixology/core`.
- `modules`: modules for use by other module systems.
- `schemas`: flake schemas for documented outputs.

Run `nix flake show` to inspect the current output tree.

## Component Groups

### `nixology.flake`

Components for standard flake-parts outputs:

- `apps`
- `bundlers`
- `checks`
- `darwinConfigurations`
- `darwinModules`
- `devShells`
- `flakeModules`
- `formatter`
- `homeConfigurations`
- `homeModules`
- `legacyPackages`
- `modules`
- `nixosConfigurations`
- `nixosModules`
- `overlays`
- `packages`

These components import the corresponding flake-parts modules and attach flake
schemas where available.

### `nixology.extra`

Additional flake-parts modules:

- `easyOverlay`: imports the upstream flake-parts `easyOverlay` module.
- `shellEnvs`: defines `perSystem.shellEnvs` and turns each shell environment
  into a `devShells` output.
- `modular`: defines `mod.*` options for grouping component modules and
  aggregate modules across module classes.

### `nixology.tools`

Development tooling components:

- `treefmt`: imports `treefmt-nix` and depends on formatter/check outputs.
- `git-hooks`: imports `git-hooks.nix` and wires enabled pre-commit packages
  into the default shell environment.

### `nixology.environments`

Ready-made development environments:

- `nix`: adds Nix development tools and default formatters for Nix code.

### `nixology.core`

Core components from `nixology/core` are re-exported for convenience.

## Shell Environments

The `nixology.extra.shellEnvs` component adds a `perSystem.shellEnvs` option.
Each entry becomes a development shell with the same name.

```nix
perSystem =
  { pkgs, ... }:
  {
    shellEnvs.default = {
      packages = with pkgs; [
        just
        nil
      ];
      shellHook = ''
        echo "ready"
      '';
    };
  };
```

Supported shell environment fields are:

- `packages`
- `inputsFrom`
- `shellHook`
- `stdenv`
- `mkShellOverrides`

## Development

Enter the default development shell:

```sh
nix develop
```

Format the repository:

```sh
nix fmt
```

Run checks:

```sh
nix flake check
```

Update locked inputs:

```sh
just update
```

## Partitioned Inputs

Development-only and schema-only inputs live in partition flakes:

- `partitions/development`: `treefmt-nix`, `git-hooks.nix`, and the development
  package channel.
- `partitions/schemas`: flake schema inputs.

The root flake maps `checks`, `devShells`, and `formatter` into the development
partition, and `schemas` into the schemas partition.

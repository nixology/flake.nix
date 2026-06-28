local@{ ... }:
let
  inherit (local.config.partitions.schemas.extraInputs) flake-schemas;

  descriptions = {
    apps = "runnable programs";
    checks = "derivations for testing evaluation of this flake";
    devShells = "development shells";
    formatter = "project formatter";
    legacyPackages = "nested attribute sets of nixpkgs packages";
    nixosConfigurations = "NixOS configurations";
    nixosModules = "NixOS modules";
    overlays = "nixpkgs overlays";
    packages = "nixpkgs packages";
  };

  mkComponent =
    name: shortDescription:
    let
      implementation = {
        imports = [
          "${local.inputs.core.inputs.flake-parts}/modules/${name}.nix"
        ];

        config.flake.schemas.${name} = flake-schemas.exportedSchemas.${name};
      };
    in
    {
      inherit implementation;

      dependencies = with local.inputs.self.components; [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide the `${name}` flake output for ${shortDescription}.";
        inherit shortDescription;
      };
    };

  parts = builtins.mapAttrs mkComponent descriptions;
in
{
  imports = map (component: component.implementation) [
    parts.checks
    parts.devShells
    parts.formatter
  ];

  flake.components = {
    nixology.flake = parts;
  };
}

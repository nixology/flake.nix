local@{ ... }:
let
  inherit (local.inputs.core.components) nixology;
in
{
  imports = map (component: component.module) [
    nixology.core.components
    nixology.core.lib
    nixology.core.partitions
  ];
}

local@{ ... }:
let
  inherit (local.inputs.core.lib.components) uses;
  inherit (local.inputs.core.components) nixology;
in
uses {
  components = [
    nixology.core.components
    nixology.core.lib
    nixology.core.partitions
  ];
}

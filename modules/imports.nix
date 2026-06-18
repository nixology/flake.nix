{ inputs, ... }:
{
  imports =
    with inputs.core.components;
    map (component: component.module) [
      nixology.core.components
      nixology.core.lib
      nixology.core.partitions
    ];
}

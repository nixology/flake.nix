local@{ ... }:
{
  imports =
    with local.inputs.core.components;
    map (component: component.module) [
      nixology.core.components
      nixology.core.lib
      nixology.core.partitions
    ];
}

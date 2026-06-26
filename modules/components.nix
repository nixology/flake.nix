local@{ ... }:
{
  # export core components as top-level components
  flake.components = local.inputs.core.components;
}

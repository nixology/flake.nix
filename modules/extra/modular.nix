{ inputs, ... }:
let
  implementation =
    { config, lib, ... }:
    let
      cfg = config;

      # Flattens a tree of components into a single-level attribute set,
      # with keys representing the path to each leaf node, separated by dots.
      flattenComponents =
        { tree, isLeaf }:
        let
          recurse =
            path: value:
            if isLeaf value then
              { ${lib.concatStringsSep "." path} = value; }
            else if lib.isAttrs value then
              lib.foldl' lib.mergeAttrs { } (lib.mapAttrsToList (name: v: recurse (path ++ [ name ]) v) value)
            else
              { };
        in
        recurse [ ] tree;

      # Transposes a two-level attribute set, swapping the outer and inner keys.
      transpose =
        attrsOfAttrs:
        let
          outerKeys = builtins.attrNames attrsOfAttrs;
          innerKeys = lib.unique (lib.concatMap builtins.attrNames (builtins.attrValues attrsOfAttrs));
        in
        lib.genAttrs innerKeys (
          innerKey:
          lib.genAttrs outerKeys (
            outerKey:
            if builtins.hasAttr innerKey (attrsOfAttrs.${outerKey}) then
              attrsOfAttrs.${outerKey}.${innerKey}
            else
              null
          )
        );

      # TODO: need to map over all components in the flake-parts module
      # TODO: usually there is only one, but there can be more than one

      # Transposes the 'component' attribute of a flake-parts module
    in
    {
      options.mod =
        let
          data =
            with lib.types;
            submoduleWith {
              modules = [
                {
                  freeformType =
                    let
                      message = ''
                        No option has been declared for this mod data attribute, so its definitions can't be merged automatically.
                        Possible solutions:
                          - Load a module that defines this mod data attribute
                          - Declare an option for this mod data attribute
                          - Make sure the data attribute is spelled correctly
                          - Define the value only once, with a single definition in a single module
                      '';
                    in
                    lazyAttrsOf (unique { inherit message; } raw);
                }
              ];
            };

          evaluator =
            with lib.types;
            submodule (
              { ... }:
              {
                options = {
                  evaluator = lib.mkOption {
                    type = functionTo attrs;
                    description = "Function for evaluating an aggregate module.";
                  };
                  aggregate = lib.mkOption {
                    type = str;
                    description = "Aggregate module to be evaluated.";
                  };
                  otherArgs = lib.mkOption {
                    type = attrs;
                    description = "Additional arguments to be passed to the evaluator function.";
                    default = { };
                  };
                };
              }
            );

          components =
            with lib.types;
            let
              components = submodule {
                options = {
                  _ = lib.mkOption {
                    description = "Nested component modules.";
                    type = components;
                    visible = false;
                  };
                };
              };
            in
            lazyAttrsOf (oneOf [
              component
              components
            ]);

          component =
            with lib.types;
            addCheck (attrsOf deferredModule) (
              component:
              let
                classes = builtins.attrNames component;
                unknownClasses = lib.filter (class: !lib.elem class cfg.mod.classes) classes;
              in
              unknownClasses == [ ]
            )
            // {
              name = "component";
              description = ''

                {
                  ${lib.concatMapStringsSep "\n  " (
                    class: "${class} = <module>; # optional - only for ${class} modules"
                  ) cfg.mod.classes}
                }

                Notes:
                  - Make sure the attribute key is spelled correctly [${
                    lib.concatMapStringsSep ", " (class: class) cfg.mod.classes
                  }]
                  - Add the new class name to `mod.classes` if needed

              '';
            };
        in
        {
          data = lib.mkOption {
            type = data;
            description = "Metadata for sharing across modules of diffrent module systems.";
          };

          classes = lib.mkOption {
            type = with lib.types; listOf str;
            description = "List of valid module classes.";
            default = [
              "flake"
              "nixos"
              "darwin"
              "homeManager"
            ];
          };

          component = lib.mkOption {
            type = components;
            description = "Collection of component modules.";
            default = { };
          };

          aggregate = lib.mkOption {
            type = with lib.types; lazyAttrsOf (lazyAttrsOf (listOf attrs));
            description = "Collection of aggregate modules.";
            default = { };
          };

          evaluation = lib.mkOption {
            type = evaluator;
            description = "Collection of evaluation modules.";
            default = { };
          };
        };

      config =
        let
          isComponent = value: lib.any (class: value ? ${class}) cfg.mod.classes;
          flattenedComponents = flattenComponents {
            tree = cfg.mod.component;
            isLeaf = isComponent;
          };
          transposedComponents = transpose flattenedComponents;
        in
        {
          # create flake.modules for all components and aggregates
          flake.modules =
            let
              wrapModules = name: class: kind: modules: {
                _class = class;

                # Use unique `key` to dedup anonymous modules
                key = "${name}:${class}:${kind}";

                imports = modules;
              };

              components = lib.mapAttrs (
                class: namedModules:
                lib.mapAttrs (name: module: wrapModules name class "component" [ module ]) namedModules
              ) transposedComponents;

              aggregates =
                let
                  # Recursively collect components
                  componentsFor =
                    aggregate:
                    let
                      direct = map (component: component) (aggregate.components or [ ]);
                      nested = builtins.foldl' (acc: agg: acc ++ componentsFor agg) [ ] (aggregate.aggregates or [ ]);
                    in
                    (direct ++ nested);

                  aggregates = transpose (
                    lib.mapAttrs (
                      name: aggregate:
                      let
                        components = componentsFor aggregate;
                      in
                      lib.mapAttrs (class: modules: wrapModules name class "aggregate" modules) (lib.zipAttrs components)
                    ) cfg.mod.aggregate
                  );
                in
                aggregates;

            in
            lib.attrsets.recursiveUpdate components aggregates;
        };
    };

  component = {
    inherit implementation;
    dependencies = with inputs.self.components; [
      nixology.flake.modules
    ];
  };
in
{
  imports = [ implementation ];
  flake.components = {
    nixology.extra.modular = component;
  };
}

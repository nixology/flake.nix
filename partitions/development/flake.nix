{
  description = "private inputs for development purposes.";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    main.url = "path:../..";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "main/core/nixpkgs";
    };

    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "main/core/nixpkgs";
    };
  };
}

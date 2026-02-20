{
  description = "Personal Nix packages";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          repo-prompt = pkgs.callPackage ./pkgs/repo-prompt/package.nix {};
          wispr-flow = pkgs.callPackage ./pkgs/wispr-flow/package.nix {};
        }
      );
    };
}

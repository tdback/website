{
  description = "tdback's website source code (tdback.net)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      eachSystem = nixpkgs.lib.genAttrs supportedSystems;
      forPkgs =
        fn:
        nixpkgs.lib.mapAttrs (system: pkgs: (fn pkgs)) (
          nixpkgs.lib.getAttrs supportedSystems nixpkgs.legacyPackages
        );
    in
    {
      packages = forPkgs (pkgs: {
        default = pkgs.callPackage ./default.nix { };
      });

      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = with pkgs; mkShell {
            buildInputs = [ hugo ];
          };
        }
      );
    };
}

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            hugo
          ];

          shellHook = ''
            SITE="$HOME/projects/tdback.net"

            new-post() {
              hugo new "posts/$1/index.md"
              $EDITOR "$SITE/content/posts/$1/index.md"
            }

            del-post() {
              POST="$SITE/content/posts/$1"
              [ -d $POST ] && rm -r $POST
            }
          '';
        };
      });
}

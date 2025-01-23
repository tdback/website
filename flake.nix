{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      eachSystem = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              hugo
              rsync
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

              deploy() {
                hugo && rsync -avz --delete public/ thor:/var/www/tdback.net/
              }
            '';
          };
        }
      );
    };
}

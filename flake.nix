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

              publish() {
                hugo && rsync -avz --delete public/ thor:/var/www/tdback.net/
              }
            '';
          };
        }
      );
    };
}

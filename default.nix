{
  hugo,
  lib,
  stdenv,
  self ? null,
}:
stdenv.mkDerivation {
  pname = "tdback-net";
  version = if self ? rev then self.rev else "dirty";
  src = lib.cleanSource ./.;

  nativeBuildInputs = [ hugo ];

  buildPhase = ''
    runHook preBuild

    hugo build --minify

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mv public $out

    runHook postInstall
  '';
}

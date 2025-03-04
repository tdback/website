{
  hugo,
  stdenv,
  self ? null
}:
stdenv.mkDerivation {
  pname = "tdback-net";
  version = if self ? rev then self.rev else "dirty";
  src = ./.;

  nativeBuildInputs = [ hugo ];

  buildPhase = ''
    hugo build --minify
  '';

  installPhase = ''
    mv public $out
  '';
}

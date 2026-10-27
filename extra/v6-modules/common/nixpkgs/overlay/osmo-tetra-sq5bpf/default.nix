{ lib, stdenv, fetchFromGitHub, libosmocore, talloc, gnutls, callPackage }:

stdenv.mkDerivation rec {
  pname = "osmo-tetra-sq5bpf";
  version = "4e9f1b23b460a6b24270ece685ac68d4d7fd4cc8";

  src = fetchFromGitHub {
    owner = "sq5bpf";
    repo = "osmo-tetra-sq5bpf";
    rev = version;
    sha256 = "sha256-tjaf5ex+RhwAIr9U7i8ZEyyErk2oYKs5ykU6SCsCbOQ=";
  };

  propagatedBuildInputs = [
    talloc
  ];

  nativeBuildInputs = [
    (callPackage ../libosmocore-sq5bpf { })
  ];

  preBuild = ''
    ls
    cd src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp tetra-rx $out/bin
    mkdir -p $out/lib/$pname
    cp -r demod $out/lib/$pname/demod
  '';

  meta = with lib; {
    description = "Library facilitating decoding and encoding TETRA MAC/PHY layer";
    homepage = "https://github.com/sq5bpf/osmo-tetra-sq5bpf";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}

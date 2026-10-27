{ lib, stdenv, fetchFromGitHub, libxml2, ncurses, pkg-config, callPackage }:

stdenv.mkDerivation rec {
  pname = "telive";
  version = "6b24f7a489b79912ec6e6c54f24c4987bb6805d9";

  src = fetchFromGitHub {
    owner = "sq5bpf";
    repo = "telive";
    rev = version;
    sha256 = "sha256-OLghxwOg8CUvvPsV/oSZc6jbinmkICMevoBifQLaVGc";
  };

  nativeBuildInputs = [
    libxml2
    ncurses
    pkg-config
    (callPackage ../libosmocore-sq5bpf { })
    (callPackage ../osmo-tetra-sq5bpf { })
  ];

  postBuild = ''
    sed -i "s:/tetra/bin/::g" bin/tplay
    sed -i "s:/TDIR=/tetra/in:in:g" bin/tplay
    sed -i "s:/ODIR=/tetra/out:out:g" bin/tplay
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp telive bin/* $out/bin
  '';

  meta = with lib; {
    description = "Tetra live monitor";
    homepage = "https://github.com/sq5bpf/telive";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}

{ lib, stdenv, fetchFromGitHub, libxml2, ncurses, pkg-config, callPackage }:

stdenv.mkDerivation rec {
  pname = "telive";
  version = "34c9871d17309b7793648b18a35b850382c53236";

  src = fetchFromGitHub {
    owner = "adryd325";
    repo = "telive";
    rev = version;
    sha256 = "sha256-y2R84q08b1kaAu+Pr/Gj3D/XnMVq4IscgD6F/d0a7Bg=";
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

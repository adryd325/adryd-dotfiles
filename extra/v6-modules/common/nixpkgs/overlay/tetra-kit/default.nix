{ lib, stdenv, fetchFromGitLab, callPackage, rapidjson, zlib, sox, ncurses }:

stdenv.mkDerivation rec {
  pname = "tetra-kit";
  version = "v1.1";

  src = fetchFromGitLab {
    owner = "larryth";
    repo = "tetra-kit";
    rev = version;
    sha256 = "sha256-kKxcYECsvavLXMC7WQ8HyIcgi3SGauU88JZq4Zn+RVo=";
  };

  propagatedBuildInputs = [
    rapidjson
    zlib
    sox
    ncurses
  ];

  buildPhase = ''
    ./build.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp decoder/decoder recorder/recorder codec/cdecoder codec/sdecoder $out/bin
  '';

  meta = with lib; {
    description = "Set of Osmocom core libraries";
    homepage = "https://github.com/osmocom/libosmocore";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}

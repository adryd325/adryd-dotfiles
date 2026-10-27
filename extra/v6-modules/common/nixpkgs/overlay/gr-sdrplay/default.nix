{ lib, mkDerivation, stdenv, fetchFromGitHub, gnuradio3_7, cmake, boost, git, cppunit, sdrplay, python27, doxygen, swig }:

mkDerivation rec {
  pname = "gr-sdrplay";
  version = "aee810a5d51ceefec4fdf76d7fb3cd76f4fb9a35";

  src = fetchFromGitHub {
    owner = "fventuri";
    repo = "gr-sdrplay";
    rev = version;
    sha256 = "sha256-R6X9bG6GBxX/lR+OUbaFlcGSDJF65ac+N/GXHeMPX64=";
  };

  buildInputs = [
    gnuradio3_7
    boost
    cppunit
    sdrplay
    python27
    doxygen
    swig
  ];

  nativeBuildInputs = [ cmake git ];

  meta = with lib; {
    description = "asdf";
    homepage = "https://github.com/fventuri/gr-sdrplay";
    platforms = platforms.linux;
  };
}

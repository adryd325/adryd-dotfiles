{ lib
, stdenv
, mkDerivation
, fetchFromGitHub
, gnuradio
, cmake
, boost
, git
, cppunit
, sdrplay
, python310
, log4cpp
, mpir
, python310Packages
, gmpxx
, doxygen
}:

mkDerivation rec {
  pname = "gr-sdrplay";
  version = "3.9.0.1";

  src = fetchFromGitHub {
    owner = "fventuri";
    repo = "gr-sdrplay3";
    rev = "v${version}";
    hash = "sha256-+enPjoMZxdW2eukaziydiEvv4KR22+Uw5kinCf/Oits=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gnuradio
    boost
    git
    cppunit
    sdrplay
    python310
    log4cpp
    mpir
    python310Packages.pybind11
    python310Packages.six
    python310Packages.numpy
    gmpxx
    doxygen
  ];

  meta = with lib; {
    description = "asdf";
    homepage = "https://github.com/fventuri/gr-sdrplay";
    platforms = platforms.linux;
  };
}

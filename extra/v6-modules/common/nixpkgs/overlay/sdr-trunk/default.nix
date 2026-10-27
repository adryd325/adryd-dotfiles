{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "sdr-trunk";
  version = "0.6.0";

  src = fetchzip {
    url = "https://github.com/DSheirer/sdrtrunk/releases/download/v0.6.0/sdr-trunk-linux-x86_64-v0.6.0.zip";
    hash = "sha256-zD/kqdULH3o2n4JiI9RD7VRBgOF0VzI/9nAFKk5XTeI=";
    stripRoot = true;
  };

  buildPhase = ''
  '';

  installPhase = ''
    mkdir $out
    cp -r bin $out
    cp -r conf $out
    cp -r legal $out
    cp -r lib $out
  '';

  meta = with lib; {
    description = "SDR Trunk";
    homepage = "https://github.com/DSheirer/sdrtrunk";
    platforms = platforms.linux;
  };
}

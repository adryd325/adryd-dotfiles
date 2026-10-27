{ lib, stdenv, fetchzip, fetchpatch, rename }:

stdenv.mkDerivation rec {
  pname = "etsi-tetra-codec-sq5bpf";
  version = "01.03.01_60";

  src = fetchzip {
    url = "https://www.etsi.org/deliver/etsi_en/300300_300399/30039502/01.03.01_60/en_30039502v010301p0.zip";
    hash = "sha256-fQV+C4ypZn3BMXTAWImPlrPSt+3O+H+i4XIyb9OB+cU=";
    stripRoot = false;
  };

  prePatch = ''
    rename 'y/A-Z/a-z/' *
    rename 'y/A-Z/a-z/' **/*
  '';

  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/sq5bpf/install-tetra-codec/master/codec.diff";
      hash = "sha256-HM5KGt34GC70djDzxMrXQsybICY+IBKLKxOd3HJvmnA=";
    })
  ];

  nativeBuildInputs = [ rename ];

  buildPhase = ''
    cd c-code
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp sdecoder scoder cdecoder ccoder $out/bin
  '';

  meta = with lib; {
    description = "Tetra codec";
    homepage = "https://github.com/sq5bpf/install-tetra-codec";
    platforms = platforms.linux;
  };
}

{ lib, stdenv, fetchFromGitHub, libosmocore, talloc, gnutls, callPackage }:

stdenv.mkDerivation rec {
  pname = "osmo-tetra-sq5bpf";
  version = "d81a4c4d02d35361f92648cfbbecc12b28033304";

  src = fetchFromGitHub {
    owner = "adryd325";
    repo = "osmo-tetra-sq5bpf";
    rev = version;
    sha256 = "sha256-Rtqh33FAEI9Nm1i/StKZOupLUuwGHDLGdkatumRT0K8=";
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

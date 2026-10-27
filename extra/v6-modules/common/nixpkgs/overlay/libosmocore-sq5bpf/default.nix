{ lib, stdenv, fetchFromGitHub, autoreconfHook, pkg-config, pcsclite, talloc, python2, gnutls }:

stdenv.mkDerivation rec {
  pname = "libosmocore-sq5bpf";
  version = "c2c042dfd796dae243d84b32e56e01ea5484ad21";

  src = fetchFromGitHub {
    owner = "osmocom";
    repo = "libosmocore";
    rev = version;
    sha256 = "sha256-W/1gfdz2KW24AUN1J0INmQSxO/9oQfP7a856wsR1Mqo=";
  };

  propagatedBuildInputs = [
    talloc
  ];

  nativeBuildInputs = [
    autoreconfHook pkg-config
  ];

  buildInputs = [
    pcsclite python2 gnutls
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Set of Osmocom core libraries";
    homepage = "https://github.com/osmocom/libosmocore";
    license = licenses.agpl3;
    platforms = platforms.linux;
  };
}

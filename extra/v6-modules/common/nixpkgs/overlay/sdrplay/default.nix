{ stdenv, lib, fetchurl, autoPatchelfHook, udev, libusb }:
let
  arch = if stdenv.isx86_64  then "x86_64"
    else if stdenv.isi686    then "i686"
    else if stdenv.isAarch64 then "aarch64"
    else if stdenv.isAarch32 then "armv7l"
    else throw "unsupported architecture";
in stdenv.mkDerivation rec {
  pname = "sdrplay";
  version = "3.07.1";

  src = fetchurl {
    url = if stdenv.isx86_64 then "https://www.sdrplay.com/software/SDRplay_RSP_API-Linux-${version}.run"
      else if stdenv.isi686 then "https://www.sdrplay.com/software/SDRplay_RSP_API-Linux-${version}.run"
      else if stdenv.isAarch64 then "https://www.sdrplay.com/software/SDRplay_RSP_API-ARM64-${version}.run"
      else if stdenv.isAarch32 then "https://www.sdrplay.com/software/SDRplay_RSP_API-ARM32-${version}.run"
      else throw "unsupported architecture";
    sha256 = if stdenv.isx86_64 then "sha256-rv6HM8uj5IAVfChDnB7Vq3V3JKeib+dO7pLNpvNhRag="
      else if stdenv.isi686 then "sha256-rv6HM8uj5IAVfChDnB7Vq3V3JKeib+dO7pLNpvNhRag="
      else if stdenv.isAarch64 then "sha256-GJPFW6W8Ke4mnczcSLFYfioOMGCfFn2/EIA07VnmVGY="
      else if stdenv.isAarch32 then "todo"
      else throw "unsupported architecture";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ udev stdenv.cc.cc.lib libusb ];

  unpackPhase = ''
    sh "$src" --noexec --target source
  '';

  sourceRoot = "source";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/{bin,lib,include,lib/udev/rules.d}
    majorVersion="${lib.concatStringsSep "." (lib.take 1 (builtins.splitVersion version))}"
    majorMinorVersion="${lib.concatStringsSep "." (lib.take 2 (builtins.splitVersion version))}"
    libName="libsdrplay_api"
    cp "${arch}/$libName.so.$majorMinorVersion" $out/lib/
    ln -s "$out/lib/$libName.so.$majorMinorVersion" "$out/lib/$libName.so.$majorVersion"
    ln -s "$out/lib/$libName.so.$majorVersion" "$out/lib/$libName.so"
    cp "${arch}/sdrplay_apiService" $out/bin/
    cp -r inc/* $out/include/
    cp 66-mirics.rules $out/lib/udev/rules.d/
  '';

  meta = with lib; {
    description = "SDRplay API";
    longDescription = ''
      Proprietary library and api service for working with SDRplay devices. For documentation and licensing details see
      https://www.sdrplay.com/docs/SDRplay_API_Specification_v${lib.concatStringsSep "." (lib.take 2 (builtins.splitVersion version))}.pdf
    '';
    homepage = "https://www.sdrplay.com/downloads/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    # license = licenses.unfree;
    maintainers = [ maintainers.pmenke ];
    platforms = platforms.linux;
  };
}

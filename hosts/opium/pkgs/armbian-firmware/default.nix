{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "armbian-firmware";
  version = "0.0.1";

  dontBuild = true;
  dontFixup = true;
  compressFirmware = false;

  # https://github.com/armbian/firmware/tree/master
  src = fetchFromGitHub {
    owner = "armbian";
    repo = "firmware";
    rev = "6c1532bccd4f99608d7f09a0f115214a7867fb0a";
    sha256 = "sha256-DlRKCLOGW15FNfuzB/Ua2r1peMn/xHBuhOEv+e3VvTk=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/firmware
    cp -a * $out/lib/firmware

    rm $out/lib/firmware/wcnmodem.bin
    rm $out/lib/firmware/wifi_2355b001_1ant.ini

    cp ./uwe5622/wcnmodem.bin $out/lib/firmware/
    cp ./uwe5622/wifi_2355b001_1ant.ini $out/lib/firmware/

    runHook postInstall
  '';
}

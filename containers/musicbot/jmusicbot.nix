{
  stdenv,
  fetchurl,
  jdk11_headless,
}:
stdenv.mkDerivation rec {
  name = "JMusicBot";
  version = "0.4.1";
  src = fetchurl {
    url = "https://github.com/jagrosh/MusicBot/releases/download/${version}/${name}-${version}.jar";
    # sha256 = "sha256-JSVrzyCqAp3V5OZ+KJczhWGolPkdaHsPmiqfmhapQMs"; # 0.4.0 is broken
    sha256 = "sha256-+0814w4zKNr2TxZ9CS8FxeuTLa71jM+DhrfFvLMFlw0=";
  };

  buildInputs = [jdk11_headless];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${name}.jar
  '';

  meta.mainProgram = "${name}.jar";
}

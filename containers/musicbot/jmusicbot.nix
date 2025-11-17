{
  stdenv,
  fetchurl,
  jdk11_headless,
}:
stdenv.mkDerivation rec {
  name = "JMusicBot";
  version = "0.4.3";
  src = fetchurl {
    url = "https://github.com/jagrosh/MusicBot/releases/download/${version}/${name}-${version}.jar";
    sha256 = "sha256-7CHFc94Fe6ip7RY+XJR9gWpZPKM5JY7utHp8C3paU9s=";
  };

  buildInputs = [jdk11_headless];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${name}.jar
  '';

  meta.mainProgram = "${name}.jar";
}

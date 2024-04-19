{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # dependencies
  imagemagick,
  feh,
  colorz,
  colorthief,
  # build
  setuptools-scm,
  # test
  unittestCheckHook,
}:
buildPythonPackage rec {
  pname = "pywal16";
  version = "3.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "eylles";
    repo = pname;
    rev = version;
    sha256 = "sha256-BazZdSf6N3kPE5/3RGpkyp01DSaIxtcgq4lK3kv2ilU";
  };

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    imagemagick
    feh
    colorz
    colorthief
  ];

  patches = [
    ./0001-convert.patch
    ./0002-feh.patch
  ];

  postPatch = ''
    substituteInPlace pywal/backends/wal.py --subst-var-by convert "${imagemagick}/bin/convert"
    substituteInPlace pywal/wallpaper.py --subst-var-by feh "${feh}/bin/feh"
  '';

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  nativeCheckInputs = [
    unittestCheckHook
  ];

  unittestFlagsArray = [
    "-s"
    "tests"
    "-v"
  ];

  meta = with lib; {
    description = "16 colors fork of pywal";
    mainProgram = "wal";
    homepage = "https://github.com/eylles/pywal16";
    license = licenses.mit;
    maintainers = with maintainers; [kylosus];
  };
}

{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # dependencies
  xdotool,
  i3ipc,
  # build
  setuptools-scm,
  # test
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "i3-layouts";
  version = "0.13.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "eliep";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-0fKFlRW8GxAO/Y3MlkOna8Fp9hUX5+eTVvRVuB7O8IU=";
  };

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    xdotool
    i3ipc
  ];

  # Fails because of /run/.../i3/... socket
  doCheck = false;
  # nativeCheckInputs = [
  #   pytestCheckHook
  # ];

  meta = with lib; {
    description = "Dynamic layouts for i3wm";
    mainProgram = "i3l";
    homepage = "https://github.com/eliep/i3-layouts";
    license = licenses.mit;
    maintainers = with maintainers; [kylosus];
  };
}

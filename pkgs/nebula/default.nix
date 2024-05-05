{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nixosTests,
}:
buildGoModule rec {
  pname = "nebula";
  version = "1.8.2-git";

  src = fetchFromGitHub {
    owner = "slackhq";
    repo = pname;
    rev = "master";
    hash = "sha256-F84yZzyRsH1bgzV+59i7qqM5+EA9PRqiwytisgEqmog";
  };

  vendorHash = "sha256-CrslSgMOBnwR3mw1T/Q2ujoJWZzA09PaGG43P66aJgQ";

  subPackages = ["cmd/nebula" "cmd/nebula-cert"];

  ldflags = ["-X main.Build=${version}"];

  passthru.tests = {
    inherit (nixosTests) nebula;
  };

  meta = with lib; {
    description = "Overlay networking tool with a focus on performance, simplicity and security";
    longDescription = ''
      Nebula is a scalable overlay networking tool with a focus on performance,
      simplicity and security. It lets you seamlessly connect computers
      anywhere in the world. Nebula is portable, and runs on Linux, OSX, and
      Windows. (Also: keep this quiet, but we have an early prototype running
      on iOS). It can be used to connect a small number of computers, but is
      also able to connect tens of thousands of computers.

      Nebula incorporates a number of existing concepts like encryption,
      security groups, certificates, and tunneling, and each of those
      individual pieces existed before Nebula in various forms. What makes
      Nebula different to existing offerings is that it brings all of these
      ideas together, resulting in a sum that is greater than its individual
      parts.
    '';
    homepage = "https://github.com/slackhq/nebula";
    changelog = "https://github.com/slackhq/nebula/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [Br1ght0ne numinit];
  };
}

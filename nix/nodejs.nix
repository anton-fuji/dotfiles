{ lib, stdenv, stdenvNoCC, fetchurl, autoPatchelfHook }:

# Temporary upstream binaries: nixpkgs still ships an affected Node.js release.
# https://nodejs.org/en/blog/vulnerability/october-2026-security-releases
let
  version = "24.22.1";
  sources = {
    aarch64-darwin = {
      platform = "darwin-arm64";
      sha256 = "89c682593d76cd44233fa53b1563264e7de9cbb189cad169135c5b4fadfbc0a7";
    };
    x86_64-darwin = {
      platform = "darwin-x64";
      sha256 = "d132557e7ee2b85af08b0c8c34338e65c6430f2238d01f727728ef42dc83b035";
    };
    aarch64-linux = {
      platform = "linux-arm64";
      sha256 = "33c37be234ba8bee041961047b19160f4d7d0f164e8e246f78bdd10feff148b3";
    };
    x86_64-linux = {
      platform = "linux-x64";
      sha256 = "eb6728e77c576a35162c122c45ccadf224d89ff00abc8dae46cc2897c6002d7c";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "nodejs";
  inherit version;
  src = fetchurl {
    url = "https://nodejs.org/dist/v${version}/node-v${version}-${source.platform}.tar.gz";
    inherit (source) sha256;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -R . "$out/"
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test "$("$out/bin/node" --version)" = "v${version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "Node.js LTS with the October 2026 security fixes";
    homepage = "https://nodejs.org/";
    license = lib.licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "node";
  };
}

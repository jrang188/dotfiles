{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_9,
  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "unocss-language-server";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "xna00";
    repo = "unocss-language-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rRi9JvjljvjBbY6UsH2YzAQcp+Z+MqxK7hhDNkpEANw=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_9;
    fetcherVersion = 1;
    hash = "sha256-E/mxy6XMTdFKVUBJApf74/L7ld/U3SUZhdYuhUaHTlo=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_9
    nodejs
  ];

  buildInputs = [
    nodejs
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/unocss-language-server}
    cp -r out node_modules package.json bin $out/lib/unocss-language-server/

    chmod +x $out/lib/unocss-language-server/bin/index.js
    ln -s $out/lib/unocss-language-server/bin/index.js $out/bin/unocss-language-server

    runHook postInstall
  '';

  meta = {
    description = "Language server for UnoCSS";
    homepage = "https://github.com/xna00/unocss-language-server";
    license = lib.licenses.mit;
    mainProgram = "unocss-language-server";
  };
})

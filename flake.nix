{
  description = "versioned mirror for ConTeXt distribution";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      overlay = final: prev:
        let
          platform = {
            aarch64-darwin = "osx-arm64";
            x86_64-linux = "linux-64";
          }.${final.system};
          isLinux = final.stdenv.hostPlatform.isLinux;
        in
        {
          update-context = final.writeShellScriptBin "update-context" ''
            # download mtxrun updater
            TMP_DIR=`mktemp -d`
            trap "rm -rf $TMP_DIR" EXIT
            ${final.wget}/bin/wget -P $TMP_DIR http://lmtx.pragma-ade.nl/install-lmtx/context-${platform}.zip
            ${final.unzip}/bin/unzip $TMP_DIR/context-${platform}.zip -d $TMP_DIR
            chmod +x $TMP_DIR/bin/mtxrun

            # download core environment
            ${final.lib.optionalString isLinux "${final.patchelf}/bin/patchelf --set-interpreter $(cat ${final.stdenv.cc}/nix-support/dynamic-linker) $TMP_DIR/bin/mtxrun"}
            $TMP_DIR/bin/mtxrun --script mtx-install.lua --update --server="lmtx.contextgarden.net,lmtx.pragma-ade.com,lmtx.pragma-ade.nl" --instance="install-lmtx" --platform="linux-64" --erase --extras=""
            $TMP_DIR/bin/mtxrun --script mtx-install.lua --update --server="lmtx.contextgarden.net,lmtx.pragma-ade.com,lmtx.pragma-ade.nl" --instance="install-lmtx" --platform="osx-arm64" --erase --extras=""

            # download modules
            GARDENRSYNC="contextgarden.net::minimals/current/modules"
            for module in $(${final.rsync}/bin/rsync "''${GARDENRSYNC}/*" | ${final.gawk}/bin/gawk '{print $NF}'); do \
              echo "Syncing ''${module}" && \
                ${final.rsync}/bin/rsync -rpztlv "''${GARDENRSYNC}/''${module}/" ./tex/texmf-modules/; \
            done
          '';

          context-bin = final.stdenvNoCC.mkDerivation rec {
            pname = "context-bin";
            version = "dev";

            src = ./.;

            nativeBuildInputs = [ final.makeWrapper ];

            # you can add custom fonts by copying them into the tex/texmf-fonts directory, e.g.
            # cp ${./fonts/consola.ttf} tex/texmf-fonts/consola.ttf
            buildPhase = ''
              mkdir -p tex/texmf-fonts
              # add your fonts here

              ${final.lib.optionalString isLinux "${final.patchelf}/bin/patchelf --set-interpreter $(cat ${final.stdenv.cc}/nix-support/dynamic-linker) tex/texmf-${platform}/bin/{luametatex,luatex}"}

              ./tex/texmf-${platform}/bin/mtxrun --generate
              ./tex/texmf-${platform}/bin/mtxrun --script cache --erase
              ./tex/texmf-${platform}/bin/mtxrun --generate
              ./tex/texmf-${platform}/bin/mtxrun --make en
            '';

            installPhase = ''
              mkdir -p $out/share/
              cp -r tex $out/share/
              makeWrapper $out/share/tex/texmf-${platform}/bin/context $out/bin/context
              makeWrapper $out/share/tex/texmf-${platform}/bin/luatex $out/bin/luatex
              makeWrapper $out/share/tex/texmf-${platform}/bin/luametatex $out/bin/luametatex
              makeWrapper $out/share/tex/texmf-${platform}/bin/mtxrun $out/bin/mtxrun
            '';
          };
        };

      defaultPackage = forAllSystems (system: (import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      }).context-bin);

      packages = forAllSystems (system: with import nixpkgs
        {
          inherit system; overlays = [ self.overlay ];
        };{ inherit context-bin update-context; });
    };
}

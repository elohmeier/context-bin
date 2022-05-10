{
  description = "versioned mirror for ConTeXt distribution";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      overlay = final: prev: {
        update-context = final.writeShellScriptBin "update-context" ''
          # download mtxrun updater
          TMP_DIR=`mktemp -d`
          trap "rm -rf $TMP_DIR" EXIT
          ${final.wget}/bin/wget -P $TMP_DIR http://lmtx.pragma-ade.nl/install-lmtx/context-linux-64.zip
          ${final.unzip}/bin/unzip $TMP_DIR/context-linux-64.zip -d $TMP_DIR
          chmod +x $TMP_DIR/bin/mtxrun

          # download core environment
          ${final.patchelf}/bin/patchelf --set-interpreter $(cat ${final.stdenv.cc}/nix-support/dynamic-linker) $TMP_DIR/bin/mtxrun
          $TMP_DIR/bin/mtxrun --script mtx-install.lua --update --server="lmtx.contextgarden.net,lmtx.pragma-ade.com,lmtx.pragma-ade.nl" --instance="install-lmtx" --platform="linux-64" --erase --extras=""

          # download modules
          GARDENRSYNC="contextgarden.net::minimals/current/modules"
          for module in $(${final.rsync}/bin/rsync "''${GARDENRSYNC}/*" | gawk '{print $NF}'); do \
            echo "Syncing ''${module}" && \
              ${final.rsync}/bin/rsync -rpztlv "''${GARDENRSYNC}/''${module}/" ./tex/texmf-modules/; \
          done
        '';
      };

      defaultPackage = forAllSystems (system: (import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      }).update-context);

      packages = forAllSystems (system: with import nixpkgs
        {
          inherit system; overlays = [ self.overlay ];
        };{ inherit update-context; });
    };
}

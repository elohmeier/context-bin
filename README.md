# ConTeXt mirror

Since the primary sources of ConTeXt only offer the latest versions of the
ConTeXt distribution for downloading, this makes it hard to consume in a
reproducible way in [Nix](https://nixos.org). This repository mirrors and
version-controls distributions from ConTeXt.

## Building ConTeXt

If you have Nix installed with [Flakes support](https://nixos.wiki/wiki/Flakes),
you can run `nix build github:elohmeier/context-bin` to download and build
the ConTeXt distribution, providing the `context`, `luametatex`, `luatex` and
`mtxrun` binaries.

## Updating ConTeXt

You can run `nix run .#update-context` on a local repo checkout.


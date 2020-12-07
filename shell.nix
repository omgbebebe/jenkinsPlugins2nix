{ nixpkgs ? import <nixpkgs> {}, unstable ? import <unstable> {}, compiler ? "ghc8101" }:
with nixpkgs;
let
  inherit (nixpkgs) pkgs;
  myghc = unstable.haskell.packages.${compiler}.ghcWithPackages (ps: with ps; [
          cabal-install
        ]);
  libs = [ zlib libsodium ];
in
pkgs.stdenv.mkDerivation {
  name = "haskelldevenv";
  buildInputs = [ pkgconfig myghc ] ++ libs;
  shellHook = ''
    eval $(egrep ^export ${ghc}/bin/ghc)
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${stdenv.lib.makeLibraryPath libs}"
  '';
}

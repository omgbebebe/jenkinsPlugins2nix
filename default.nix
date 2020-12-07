{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc8101" }:
let
  inherit (nixpkgs) pkgs;
  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};
  jenkinsPlugins2nix = import ./jenkinsPlugins2nix.nix;
  hnix = import (nixpkgs.fetchFromGitHub {
            owner = "haskell-nix";
            repo = "hnix";
            rev = "0.10.1";
            sha256 = "1df6944z31q0wh4r6v2gb1fglxsknyd5wh4574n2nn8s0bbnw06m";
            }) { inherit (nixpkgs) pkgs; compiler = compiler; };
in
haskellPackages.callPackage jenkinsPlugins2nix { hnix = pkgs.haskell.lib.dontCheck hnix; }

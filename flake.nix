{
  description = "Helm chart environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils = {
      url = "github:numtide/flake-utils";
    };
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
    };
  };
  outputs = {
    nixpkgs,
    utils,
    self,
    poetry2nix,
    ...
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [poetry2nix.overlays.default];
        };
        poetryEnv = pkgs.poetry2nix.mkPoetryEnv {
          projectDir = ./.;
        };
      in {
        devShell = with pkgs;
          mkShell {
            buildInputs = [poetryEnv kubernetes-helm awscli2 poetry];
            shellHook = ''
              pre-commit install --install-hooks
            '';
          };
      }
    );
}

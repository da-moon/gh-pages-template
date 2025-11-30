{
  description = "GitHub Pages template - Vite + TypeScript + Deno";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            deno
          ];

          shellHook = ''
            echo "gh-pages-template dev shell"
            echo "Commands: deno task dev"
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "gh-pages-template";
          version = "0.0.0";
          src = ./.;

          buildInputs = with pkgs; [
            deno
          ];

          buildPhase = ''
            export HOME=$(mktemp -d)
            export DENO_DIR=$(mktemp -d)
            deno task build
          '';

          installPhase = ''
            mkdir -p $out
            cp -r dist/* $out/
          '';
        };
      }
    );
}

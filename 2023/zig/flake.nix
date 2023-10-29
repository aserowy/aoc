{
  description = "aoc zig 2023";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };


  outputs = { self, nixpkgs, flake-parts }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devShells.default = with pkgs; mkShell {
          buildInputs = [
            nil
            nixpkgs-fmt
            nodejs_20

            zig
            zls
          ];

          shellHook = ''
            '';
        };
      };
    };
}

{
  description = "my project description";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" ];
      eachSystem = flake-utils.lib.eachSystem supportedSystems;
    in eachSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          pythonEnv = pkgs.python3.withPackages (ps: with ps; []);

          demo-drv = ({ stdenv }: stdenv.mkDerivation {
            name = "demo-pkg";
            src = ./src;
            buildInputs = [
              pythonEnv
            ];
            buildCommand = ''
              echo "#!${pythonEnv}" >> hello.py
              cat $src/hello.py >> hello.py
              chmod +x hello.py
            '';

            installCommand = ''
              mkdir -p $out/bin
              mv hello.py $out/bin
            '';
          });

          demo-pkg = pkgs.callPackage demo-drv {};
        in
        {
          defaultPackage = demo-pkg;
          devShells.default = with pkgs; mkShell {
            inputsFrom = [ demo-pkg ];
          };
        }
      );
}

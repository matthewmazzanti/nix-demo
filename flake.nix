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
            buildInputs = with pkgs; [
              pythonEnv
              go
              rustc
            ];
            buildCommand = ''
              mkdir -p $out/bin

              # Python
              # Python script builder, since I don't feel like learning setuptools again today
              pyfile="$out/bin/python-hello"
              echo "#!${pythonEnv}/bin/python" >> "$pyfile"
              cat $src/hello.py >> "$pyfile"
              chmod +x "$pyfile"

              # Go
              # Need to point some env vars to tmp to avoid build failures
              export GOCACHE="$TMPDIR/go-cache"
              export GOPATH="$TMPDIR/go"
              go build -o $out/bin/go-hello $src/hello.go

              # Rust
              rustc $src/hello.rs -o $out/rust-hello
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

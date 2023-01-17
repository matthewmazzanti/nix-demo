{
  description = "nix polyglot demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" ];
      eachSystem = flake-utils.lib.eachSystem supportedSystems;
    in
    eachSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          pythonEnv = pkgs.python3.withPackages (ps: with ps; [
            termcolor
          ]);

          demo-drv = ({ stdenv }: stdenv.mkDerivation {
            name = "demo-pkg";
            src = ./src;
            buildInputs = with pkgs; [
              pythonEnv
              ruby
              go
              rustc
            ];
            buildCommand = ''
              mkdir -p $out/bin

              all_file="$out/bin/all-hello"
              echo "#!${pkgs.bash}/bin/bash" > "$all_file"
              chmod +x "$all_file"

              # Python
              python_file="$out/bin/python-hello"
              # Add our python environment to the shebang
              echo "#!${pythonEnv}/bin/python" >> "$python_file"
              cat "$src/hello.py" >> "$python_file"
              chmod +x "$python_file"
              echo "$python_file" >> "$all_file"

              # Ruby
              ruby_file="$out/bin/ruby-hello"
              # Add our ruby environment to the shebang
              echo "#!${pkgs.ruby}/bin/ruby" >> "$ruby_file"
              cat "$src/hello.rb" >> "$ruby_file"
              chmod +x "$ruby_file"
              echo "$ruby_file" >> "$all_file"

              # Go
              go_file="$out/bin/go-hello"
              # Need to point some env vars to tmp to avoid build failures
              export GOCACHE="$TMPDIR/go-cache"
              export GOPATH="$TMPDIR/go"
              go build -trimpath -o "$go_file" "$src/hello.go"
              echo "$go_file" >> "$all_file"

              # Rust
              rust_file="$out/bin/rust-hello"
              rustc -o "$rust_file" "$src/hello.rs"
              echo "$rust_file" >> "$all_file"
            '';
          });

          demo-pkg = pkgs.callPackage demo-drv { };

          demo-docker = pkgs.dockerTools.buildImage {
            name = "hello-nix";
            # This is only needed for demo purposes!
            /*
            copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = with pkgs; [ bashInteractive coreutils gnugrep tree less ];
              pathsToLink = [ "/bin" ];
            };
            */
            config = {
              Cmd = [ "${demo-pkg}/bin/all-hello" ];
            };
          };
        in
        {
          packages = {
            default = demo-pkg;
            docker = demo-docker;
          };
          devShells.default = with pkgs; mkShell {
            buildInputs = [ nixpkgs-fmt nix-tree ];
            inputsFrom = [ demo-pkg ];
          };
        }
      );
}

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

          demo-pkg = pkgs.callPackage ./default.nix {};
        in
        {
          defaultPackage = demo-pkg;
          devShells.default = with pkgs; mkShell {
            inputsFrom = [ demo-pkg ];
          };
        }
      );
}

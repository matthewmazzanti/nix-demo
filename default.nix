{ stdenv }:
stdenv.mkDerivation {
  name = "demo-pkg";
  src = ./src;
  buildInputs = with pkgs; [
    pythonEnv
    go
  ];
  buildCommand = ''
    mkdir -p $out/bin

    # Add shebang
    echo "#!${pythonEnv}/bin/python" >> $out/bin/hello.py
    cat $src/hello.py >> $out/bin/hello.py
    chmod +x $out/bin/hello.py
  '';
}

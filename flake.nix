{
  description = "Python project with uv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python311;
        runtimeLibs = with pkgs; [
          portaudio
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python
            uv
            # Add any system-level dependencies here
            # e.g., postgresql, gcc, etc.
          ] ++ runtimeLibs;

          shellHook = ''
            # Create venv if it doesn't exist
            if [ ! -d .venv ]; then
              echo "Creating virtual environment..."
              uv venv
            fi

            # Activate virtual environment
            source .venv/bin/activate

            # Make runtime libraries discoverable
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}:$LD_LIBRARY_PATH"
            
            # For macOS (if you're on Darwin)
            export DYLD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}:$DYLD_LIBRARY_PATH"

            # Help pip/uv find header files during compilation
            export C_INCLUDE_PATH="${pkgs.lib.makeIncludePath runtimeLibs}:$C_INCLUDE_PATH"
            export CPLUS_INCLUDE_PATH="${pkgs.lib.makeIncludePath runtimeLibs}:$CPLUS_INCLUDE_PATH"
            
            # Help pkg-config find .pc files
            export PKG_CONFIG_PATH="${pkgs.lib.makeSearchPathOutput "dev" "lib/pkgconfig" runtimeLibs}:$PKG_CONFIG_PATH"

            # Install dependencies if needed
            if [ -f pyproject.toml ]; then
              echo "Installing dependencies with uv..."
              uv sync
            fi

            echo "Python development environment ready!"
            echo "Python: $(python --version)"
            echo "UV: $(uv --version)"
            echo "Runtime libraries: ${pkgs.lib.makeLibraryPath runtimeLibs}"
          '';

          # Ensure UV uses the Nix-provided Python
          UV_PYTHON = "${python}/bin/python";
        };
      }
    );
}

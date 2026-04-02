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
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python
            uv
            # Add any system-level dependencies here
            # e.g., postgresql, gcc, etc.
          ];

          shellHook = ''
            # Create venv if it doesn't exist
            if [ ! -d .venv ]; then
              echo "Creating virtual environment..."
              uv venv
            fi

            # Activate virtual environment
            source .venv/bin/activate

            # Install dependencies if needed
            if [ -f pyproject.toml ]; then
              echo "Installing dependencies with uv..."
              uv sync
            fi

            echo "Python development environment ready!"
            echo "Python: $(python --version)"
            echo "UV: $(uv --version)"
          '';

          # Ensure UV uses the Nix-provided Python
          UV_PYTHON = "${python}/bin/python";
        };
      }
    );
}

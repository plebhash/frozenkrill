{
  description = "frozenkrill: a minimalist Bitcoin wallet focused on cold storage";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, crane, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        craneLib = crane.lib.${system};
        frozenkrill = craneLib.buildPackage {
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          strictDeps = true;
          doCheck = false;

          buildInputs = [
            pkgs.git
          ];
        };
      in
      {
        checks = {
          inherit frozenkrill;
        };

        packages.default = frozenkrill;

        apps.default = flake-utils.lib.mkApp {
          drv = frozenkrill;
        };

        devShells.default = craneLib.devShell {
          checks = self.checks.${system};

          packages = [];
        };
      });
}

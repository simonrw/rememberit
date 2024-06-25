{
  description = "Flake utils demo";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
        ];

        pkgs = import nixpkgs {
          inherit overlays system;
          config.allowUnfree = true;
        };
      in
      {
        devShells = rec {
          default = empty;

          empty = pkgs.mkShell {
            buildInputs = with pkgs; [
              nodejs
              # elmPackages.elm
              # elmPackages.elm-format
              # elmPackages.elm-live
            ] ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
              playwright
            ]);

            env = {} // (pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
              PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers;
              PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;
            });
          };
        };
      }
    );
}

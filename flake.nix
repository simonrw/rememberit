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

        playwright-browsers = import ./nix/playwright-browsers.nix {
          inherit pkgs;
          playwright_version = "1.22.0";
          data_sha256 = "sha256:1jbq5xdklw2n8cqxjv912q124wmlqkwv6inlf6qw76x9ns16lv18";
        };

      in
      {
        devShells = rec {
          default = empty;

          empty = pkgs.mkShell {
            buildInputs = with pkgs; [
              playwright
            ];

            PLAYWRIGHT_CHROMIUM = playwright-browsers.chromium;
          };
        };
      }
    );
}

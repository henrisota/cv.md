{
  description = "CV rendered from Markdown and CSS to PDF";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default =
          pkgs.runCommand "cv"
            {
              src = pkgs.lib.fileset.toSource {
                root = ./src;
                fileset = ./src;
              };
              nativeBuildInputs = [
                pkgs.pandoc
                pkgs.python3Packages.weasyprint
              ];
              # Only fonts listed here are visible, so the PDF looks the same on every machine
              FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.lato ]; };
            }
            ''
              export XDG_CACHE_HOME=$TMPDIR
              mkdir -p $out
              pandoc $src/main.md --template $src/index.html --output cv.html
              weasyprint --base-url $src cv.html $out/cv.pdf
            '';
      });

      checks = forAllSystems (pkgs: {
        cv = self.packages.${pkgs.stdenv.hostPlatform.system}.default;

      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            pkgs.just
            pkgs.watchexec
          ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}

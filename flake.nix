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

      maxPages = 1;
      # Parsers and recruiters file the CV under this name
      fileName = "Theo-Harmon-CV.pdf";
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
              weasyprint --pdf-tags --base-url $src cv.html $out/${fileName}
            '';
      });

      checks = forAllSystems (pkgs: {
        cv = self.packages.${pkgs.stdenv.hostPlatform.system}.default;

        # Applicant tracking systems read the extracted text, not the rendering
        cv-text =
          pkgs.runCommand "cv-text"
            {
              nativeBuildInputs = [
                pkgs.pandoc
                pkgs.poppler-utils
              ];
              pdf = "${self.packages.${pkgs.stdenv.hostPlatform.system}.default}/${fileName}";
            }
            ''
              pages=$(pdfinfo $pdf | awk '/^Pages:/ { print $2 }')
              if [ "$pages" -gt ${toString maxPages} ]; then
                echo "${fileName} has $pages pages, expected at most ${toString maxPages}"
                exit 1
              fi

              # Lost spaces and unmapped glyphs show up as source words missing from the extracted text
              words() { tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '\n' | sort -u; }
              pandoc --to plain ${./src/main.md} | words > expected
              pdftotext -raw $pdf - | words > extracted
              missing=$(comm -23 expected extracted)
              if [ -n "$missing" ]; then
                echo "words missing from extracted text:" $missing
                exit 1
              fi
              touch $out
            '';

      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            pkgs.just
            pkgs.watchexec
            pkgs.poppler-utils
          ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}

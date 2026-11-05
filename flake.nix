{
  description = "CV rendered from Markdown and CSS to PDF";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
    }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      maxPages = 1;
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

        # Applicant tracking systems read the extracted text, not the rendering
        cv-text =
          pkgs.runCommand "cv-text"
            {
              nativeBuildInputs = [ pkgs.poppler-utils ];
              pdf = "${self.packages.${pkgs.stdenv.hostPlatform.system}.default}/cv.pdf";
            }
            ''
              pages=$(pdfinfo $pdf | awk '/^Pages:/ { print $2 }')
              if [ "$pages" -gt ${toString maxPages} ]; then
                echo "cv.pdf has $pages pages, expected at most ${toString maxPages}"
                exit 1
              fi

              pdftotext -raw $pdf - | tr -s '[:space:]' ' ' > text
              grep -E '^#+ ' ${./src/main.md} | sed -E 's/^#+ //; s/ *`[^`]*`$//' | while read -r heading; do
                if ! grep -qiF "$heading" text; then
                  echo "heading missing from extracted text: $heading"
                  exit 1
                fi
              done
              touch $out
            '';

        git-hooks = git-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
          src = ./.;
          hooks = {
            check-case-conflicts.enable = true;
            check-merge-conflicts.enable = true;
            end-of-file-fixer.enable = true;
            trim-trailing-whitespace.enable = true;

            yamlfmt.enable = true;
            yamllint.enable = true;
            actionlint.enable = true;
            zizmor.enable = true;

            rumdl.enable = true;
            typos.enable = true;

            nixfmt.enable = true;
            deadnix.enable = true;
            statix.enable = true;
          };
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          inherit (self.checks.${pkgs.stdenv.hostPlatform.system}.git-hooks) shellHook;
          packages = self.checks.${pkgs.stdenv.hostPlatform.system}.git-hooks.enabledPackages ++ [
            pkgs.just
            pkgs.watchexec
            pkgs.poppler-utils
          ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}

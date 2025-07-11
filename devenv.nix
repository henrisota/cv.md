{
  pkgs,
  lib,
  ...
}: let
  gotenbergImage = "gotenberg/gotenberg:8";
  gotenbergPort = "3000";

  outputDirectory = "output";
in {
  packages = with pkgs; [
    curl
    exiftool
    fswatch
    findutils
  ];

  scripts = {
    build-cv.exec = ''
      mkdir -p ${outputDirectory}
      ${lib.getExe pkgs.curl} --request POST http://localhost:${gotenbergPort}/forms/chromium/convert/markdown \
        --retry 3 \
        --retry-delay 0 \
        --retry-all-errors \
        --form files=@src/index.html \
        --form files=@src/main.md \
        --form files=@src/styles.css \
        --form paperWidth=210.0mm \
        --form paperHeight=297.0mm \
        --form marginTop=5mm \
        --form marginBottom=5mm \
        --form marginLeft=5mm \
        --form marginRight=5mm \
        -o ${outputDirectory}/cv.pdf
      ${lib.getExe pkgs.exiftool} -all:all= -overwrite_original ${outputDirectory}/cv.pdf
    '';
    clean-gotenberg.exec = ''
      docker ps -a -q --filter ancestor=${gotenbergImage} | ${lib.getExe' pkgs.findutils "xargs"} -r docker rm --force
    '';
    clean.exec = ''
      rm -f ${outputDirectory}/cv.pdf
    '';
    setup-gotenberg.exec = ''
      clean-gotenberg
      docker run --name gotenberg --rm --detach --publish "${gotenbergPort}:${gotenbergPort}" ${gotenbergImage}
    '';
    setup.exec = ''
      setup-gotenberg
    '';
    write-cv.exec = ''
      ${lib.getExe pkgs.fswatch} -o src | ${lib.getExe' pkgs.findutils "xargs"} -n1 -I{} build-cv
    '';
  };

  tasks = {
    "setup:setup" = {
      exec = "setup";
      before = ["devenv:enterShell"];
    };
  };

  git-hooks.hooks = {
    check-case-conflicts.enable = true;
    check-merge-conflicts.enable = true;
    editorconfig-checker.enable = false;

    end-of-file-fixer.enable = true;
    trim-trailing-whitespace.enable = true;

    yamlfmt.enable = true;
    yamllint.enable = true;

    alejandra.enable = true;
    deadnix = {
      enable = true;
      args = ["--edit"];
    };
    statix = {
      enable = true;
      args = ["fix" "-i" ".devenv"];
    };
  };

  cachix.enable = false;
}

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

  processes.build.exec = ''
    ${lib.getExe pkgs.fswatch} -o src |
    ${lib.getExe' pkgs.findutils "xargs"} -n1 -I{} build
  '';

  scripts = {
    build.exec = ''
      mkdir -p ${outputDirectory}
      ${lib.getExe pkgs.curl} --request POST http://localhost:${gotenbergPort}/forms/chromium/convert/markdown \
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

    clean.exec = ''
      mkdir -p ${outputDirectory}
      rm ${outputDirectory}/cv.pdf
      process-compose down
    '';
  };

  tasks = {
    "setup:gotenberg" = {
      exec = ''
        docker ps -a -q --filter ancestor=${gotenbergImage} |
        ${lib.getExe' pkgs.findutils "xargs"} -r docker rm --force &&
        docker run --name gotenberg --rm --detach --publish "${gotenbergPort}:${gotenbergPort}" ${gotenbergImage}
      '';
      before = ["devenv:enterShell"];
    };
    "setup:build" = {
      exec = "build";
      before = ["devenv:enterShell"];
    };
  };

  git-hooks.hooks = {
    check-case-conflicts.enable = true;
    check-merge-conflicts.enable = true;
    editorconfig-checker.enable = false;

    end-of-file-fixer.enable = true;
    trim-trailing-whitespace.enable = true;

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

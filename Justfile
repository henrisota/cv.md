outputDirectory := "output"

build:
    nix build --out-link {{outputDirectory}}

check:
    nix flake check

watch:
    watchexec --watch src --watch flake.nix -- just build

clean:
    rm -rf {{outputDirectory}}

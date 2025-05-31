gotenbergImage := "gotenberg/gotenberg:8"
gotenbergPort := "3000"

outputDirectory := "output"

build-cv:
    mkdir -p {{outputDirectory}}
    curl --request POST http://localhost:{{gotenbergPort}}/forms/chromium/convert/markdown \
      --form files=@src/index.html \
      --form files=@src/main.md \
      --form files=@src/styles.css \
      --form paperWidth=210.0mm \
      --form paperHeight=297.0mm \
      --form marginTop=5mm \
      --form marginBottom=5mm \
      --form marginLeft=5mm \
      --form marginRight=5mm \
      -o {{outputDirectory}}/cv.pdf

clean-gotenberg:
    docker ps -a -q --filter ancestor={{gotenbergImage}} | xargs -r docker rm --force

clean:
    rm {{outputDirectory}}/cv.pdf

[private]
setup-gotenberg: clean-gotenberg
    docker run --name gotenberg --rm --detach --publish "{{gotenbergPort}}:{{gotenbergPort}}" {{gotenbergImage}}

setup: setup-gotenberg

write-cv:
    fswatch -o src | xargs -n1 -I{} build-cv

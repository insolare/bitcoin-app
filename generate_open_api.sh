go install golang.org/x/tools/cmd/goimports@latest

docker run --rm \
    -v "${PWD}:/local" \
    openapitools/openapi-generator-cli:v6.0.1 generate \
    -g go-server \
    -i /local/openapi.yaml \
    -o /local/apiserver \
    --additional-properties="packageName=apiserver,sourceFolder=,outputAsLibrary=true"

goimports -w ./apiserver

# Draw-By-Days Terraform Modules

[![Build Status](https://circleci.com/gh/SketchingDev/draw-by-days-terraform-modules/tree/master.svg?style=svg)](https://circleci.com/gh/SketchingDev/draw-by-days-terraform-modules/tree/master)

Reusable Terraform modules for [Draw-By-Days](). They have been moved into their own repository
to:
 * **Save me money** - the tests run against AWS on every commit
 * **Simplify configuration** - Terragrunt only supports absolute paths, so [modules cannot easily
 reference other modules](https://community.gruntwork.io/t/relative-paths-in-terragrunt-modules/144/6). By
 moving them out into their own repository I can create service modules that reference multiple modules
 using their URLS. Also Terragrunt cannot reference [multiple modules](https://github.com/gruntwork-io/terragrunt/issues/350). See [xyz]() for an example.


## Development

Below are the steps for running the tests locally:

```
cd draw-by-days-terraform-modules
docker run -it -v $(pwd)/lambda_api_gateway/:/go/src/app sketchingdev/golang-terratest:latest

cd test
dep init
dep ensure -v
go test -v -run TestApiGatewayReturnsLambdaResponse
```

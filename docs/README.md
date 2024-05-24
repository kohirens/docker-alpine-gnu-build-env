# Docker Docker Alpine GNU Build Env

## Build

To build the development image for testing, run:

```shell
docker compose build
```

or without Docker Compose installed

```shell
docker build -t "kohirens/docker-alpine-gnu-build-env:release" --build-arg "ALPINE_VER=3.17" --target "release" .
```

## Test

```shell
docker run -it --rm --entrypoint "" "kohirens/alpine-glibc:release"
```
